# app/services/time_slicer_service.rb
class TimeSlicerService
  NIGHT_START_HOUR = 22
  NIGHT_END_HOUR   = 6
  LATE_GRACE_MINUTES = 5
  OVERTIME_GRACE_MINUTES = 30

  def initialize(dtr)
    @dtr = dtr
    @employee = dtr.employee
    @date = dtr.date # Reporting Date for the shift

    # 1. Normalize and sequence shift times using effective helpers
    # These check the Shift Template first, then fall back to individual columns
    @shift_start = normalize_time(@employee.shift_start_time)
    @shift_end   = normalize_time(@employee.shift_end_time)
    
    # Handle Overnight Shifts
    if @shift_start && @shift_end && @shift_end < @shift_start
      @shift_end += 1.day
    end

    # 2. Rest Day Status (Shift-Basis)
    @is_shift_on_rest_day = @employee.work_days.exclude?(@date.strftime("%A"))

    # 3. Normalize break times from Template or Employee
    @break_start = normalize_time(@employee.break_start_time)
    @break_end   = normalize_time(@employee.break_end_time)
    
    if @break_start && @break_end
      @break_start += 1.day if @shift_start && @break_start < @shift_start
      @break_end   += 1.day if @break_end < @break_start
    end
  end

  def run
    # Safety Guard: If no schedule exists, return 0s to avoid crashes
    return empty_summary unless @shift_start && @shift_end
    
    slices = generate_slices
    summarize(slices)
  end

  private

  def generate_slices
    return [] unless @dtr.clock_in && @dtr.clock_out

    # ✅ Clip early clock-ins to shift start
    c_in  = [@dtr.clock_in, @shift_start].max
    c_out = @dtr.clock_out

    # Determine if Overtime qualifies
    minutes_past_shift = ((c_out - @shift_end) / 60).to_i
    qualifies_for_ot = minutes_past_shift > OVERTIME_GRACE_MINUTES

    # Define Boundaries for Slicing
    effective_out = qualifies_for_ot ? c_out : [c_out, @shift_end].min
    b = [c_in, effective_out]
    
    b << @shift_start if @shift_start&.between?(c_in, effective_out)
    b << @shift_end   if qualifies_for_ot && @shift_end.between?(c_in, effective_out)
    b << @break_start if @break_start&.between?(c_in, effective_out)
    b << @break_end   if @break_end&.between?(c_in, effective_out)
    
    # Night boundaries and Midnight transitions
    (c_in.to_date..effective_out.to_date).each do |d|
      ns = d.to_time.change(hour: NIGHT_START_HOUR)
      ne = (d + 1.day).to_time.change(hour: NIGHT_END_HOUR)
      b << ns if ns.between?(c_in, effective_out)
      b << ne if ne.between?(c_in, effective_out)
      midnight = (d + 1.day).to_time.midnight
      b << midnight if midnight.between?(c_in, effective_out)
    end

    sorted = b.compact.sort.uniq
    all_segments = sorted.each_cons(2).map do |s_t, e_t| 
      build_slice(s_t, e_t, c_in, qualifies_for_ot) 
    end

    # Remove unpaid break segments
    all_segments.reject { |s| slice_is_break?(s[:start_time], s[:end_time]) }
  end

  def build_slice(start_t, end_t, actual_in, qualifies_for_ot)
    duration = ((end_t - start_t) / 60).to_i
    current_date = start_t.to_date

    # Holiday Check
    holiday = Holiday.find_by(date: current_date)
    h_type  = holiday ? holiday.holiday_type.to_s.downcase : "none"

    # Rest Day
    is_rest = @is_shift_on_rest_day

    # Overtime & Night Diff
    is_ot    = qualifies_for_ot && start_t >= @shift_end
    is_night = start_t.hour >= NIGHT_START_HOUR || start_t.hour < NIGHT_END_HOUR

    # Multiplier
    multiplier_code = build_multiplier_code(h_type, is_rest, is_ot)
    pay_multiplier  = PayMultiplier.find_by(code: multiplier_code)
    base_rate = pay_multiplier ? pay_multiplier.base_multiplier.to_f : 1.0

    {
      start_time: start_t,
      end_time: end_t,
      minutes: duration,
      night_diff: is_night,
      overtime: is_ot,
      rest_day: is_rest,
      holiday: h_type != "none",
      multiplier_code: multiplier_code,
      multiplier_name: pay_multiplier&.name || multiplier_code.humanize,
      multiplier_percent: (base_rate * 100.0),
      late: (start_t == actual_in) ? calculate_late(actual_in) : 0
    }
  end

  def build_multiplier_code(h_type, rest, ot)
    code_parts = []
    case h_type
    when "regular"
      code_parts << "RH"
    when "special", "special non-working"
      code_parts << "SNWH"
    end
    code_parts << "RD" if rest
    code_parts << "OT" if ot

    if code_parts.empty?
      "REGULAR"
    elsif code_parts == ["OT"]
      "OD-OT"
    else
      code_parts.join("-")
    end
  end

  def slice_is_break?(s_t, e_t)
    return false unless @break_start && @break_end
    midpoint = s_t + (e_t - s_t) / 2
    midpoint.between?(@break_start, @break_end)
  end

  def calculate_late(actual_in)
    return 0 unless @shift_start
    return 0 if actual_in <= @shift_start
    diff = ((actual_in - @shift_start) / 60).to_i
    diff > LATE_GRACE_MINUTES ? diff : 0
  end

  def normalize_time(t)
    return nil unless t
    # Pin the time from the template/column to the specific DTR date in Asia/Manila
    @date.to_time.in_time_zone.change(hour: t.hour, min: t.min, sec: t.sec)
  end

  def summarize(slices)
    {
      total_work_minutes: slices.sum { |s| s[:minutes] },
      late_minutes: calculate_late(@dtr.clock_in),
      overtime_minutes: slices.select { |s| s[:overtime] }.sum { |s| s[:minutes] },
      night_diff_minutes: slices.select { |s| s[:night_diff] }.sum { |s| s[:minutes] },
      holiday_minutes: slices.select { |s| s[:holiday] }.sum { |s| s[:minutes] },
      slices: slices
    }
  end

  def empty_summary
    {
      total_work_minutes: 0,
      late_minutes: 0,
      overtime_minutes: 0,
      night_diff_minutes: 0,
      holiday_minutes: 0,
      slices: []
    }
  end
end