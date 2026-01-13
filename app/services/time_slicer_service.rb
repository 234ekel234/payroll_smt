class TimeSlicerService
  NIGHT_START_HOUR = 22
  NIGHT_END_HOUR   = 6
  NIGHT_DIFF_ADD_ON = 10.0
  LATE_GRACE_MINUTES = 5
  OVERTIME_GRACE_MINUTES = 30

  def initialize(dtr)
    @dtr = dtr
    @employee = dtr.employee
    @date = dtr.date
    # normalize_time is critical to move 2000-01-01 dates to the DTR's actual date
    @shift_start = normalize_time(@employee.shift_start)
    @shift_end   = normalize_time(@employee.shift_end)
    @break_start = normalize_time(@employee.break_start)
    @break_end   = normalize_time(@employee.break_end)
  end

  def run
    slices = generate_slices
    summarize(slices)
  end

  private

  def generate_slices
    return [] unless @dtr.clock_in && @dtr.clock_out
    c_in = @dtr.clock_in
    c_out = @dtr.clock_out

    # 1. Determine if Overtime qualifies (Must be > 30 mins)
    minutes_past_shift = ((c_out - @shift_end) / 60).to_i
    qualifies_for_ot = minutes_past_shift > OVERTIME_GRACE_MINUTES

    # 2. Define Boundaries (The points where rules change)
    # If they don't qualify for OT, we cap the work at shift_end
    effective_out = qualifies_for_ot ? c_out : [c_out, @shift_end].min
    
    b = [c_in, effective_out]
    b << @shift_start if @shift_start&.between?(c_in, effective_out)
    b << @shift_end   if qualifies_for_ot && @shift_end.between?(c_in, effective_out)
    
    # Adding break boundaries ensures we get a clean slice for the break duration
    b << @break_start if @break_start&.between?(c_in, effective_out)
    b << @break_end   if @break_end&.between?(c_in, effective_out)
    
    # Generate Night boundaries (handles overnight shifts)
    (c_in.to_date..effective_out.to_date).each do |d|
      ns = d.to_time.change(hour: NIGHT_START_HOUR)
      ne = (d + 1.day).to_time.change(hour: NIGHT_END_HOUR)
      b << ns if ns.between?(c_in, effective_out)
      b << ne if ne.between?(c_in, effective_out)
    end

    # 3. Create, Build, and Filter
    sorted = b.compact.sort.uniq
    
    # This turns [9:00, 12:00, 13:00, 18:00] into slices
    all_segments = sorted.each_cons(2).map do |s_t, e_t| 
      build_slice(s_t, e_t, c_in, qualifies_for_ot) 
    end

    # THE REJECTER: This removes the 12:00 - 1:00 slice from the list entirely
    all_segments.reject { |s| slice_is_break?(s[:start_time], s[:end_time]) }
  end

  def build_slice(start_t, end_t, actual_in, qualifies_for_ot)
    duration = ((end_t - start_t) / 60).to_i
    
    is_ot = qualifies_for_ot && start_t >= @shift_end
    is_night = start_t.hour >= NIGHT_START_HOUR || start_t.hour < NIGHT_END_HOUR
    is_rest = @employee.rest_days.include?(start_t.strftime("%a"))
    
    holiday = Holiday.find_by(date: start_t.to_date)
    h_type = holiday ? holiday.holiday_type : "none"

    multiplier_code = build_multiplier_code(h_type, is_rest, is_ot)
    pay_multiplier = PayMultiplier.find_by(code: multiplier_code)
    
    base_rate = pay_multiplier ? pay_multiplier.base_multiplier : 1.0
    final_multiplier_percent = (base_rate * 100) + (is_night ? NIGHT_DIFF_ADD_ON : 0)

    {
      start_time: start_t,
      end_time: end_t,
      minutes: duration,
      night_diff: is_night,
      overtime: is_ot,
      rest_day: is_rest,
      holiday: h_type != "none",
      multiplier_name: pay_multiplier&.name || (is_ot ? "Overtime" : "Regular Work"),
      multiplier_percent: final_multiplier_percent,
      # Marking late only on the segment that matches the actual clock-in
      late: (start_t == actual_in) ? calculate_late(actual_in) : 0
    }
  end

  def slice_is_break?(s_t, e_t)
    return false unless @break_start && @break_end
    # We check the midpoint of the slice. If 12:30 is between 12:00 and 1:00, it's a break.
    midpoint = s_t + (e_t - s_t) / 2
    midpoint.between?(@break_start, @break_end)
  end

  def build_multiplier_code(h_type, rest, ot)
    code_parts = []
    case h_type
    when "regular" then code_parts << "RH"
    when "special" then code_parts << "SNWH"
    else code_parts << "OD" if !rest && ot
    end
    code_parts << "RD" if rest
    code_parts << "OT" if ot
    code_parts.any? ? code_parts.join("-") : "REGULAR"
  end

  def calculate_late(actual_in)
    return 0 if actual_in <= @shift_start
    diff = ((actual_in - @shift_start) / 60).to_i
    diff > LATE_GRACE_MINUTES ? diff : 0
  end

  def normalize_time(t)
    return nil unless t
    # Moves the time from the database (usually Jan 1, 2000) to the DTR's actual date
    @date.to_time.change(hour: t.hour, min: t.min, sec: t.sec)
  end

  def summarize(slices)
    {
      total_work_minutes: slices.sum { |s| s[:minutes] },
      # We calculate late from the clock_in directly to ensure it's accurate 
      # even if the arrival slice was filtered out as a break.
      late_minutes: calculate_late(@dtr.clock_in),
      ot_minutes: slices.select { |s| s[:overtime] }.sum { |s| s[:minutes] },
      night_minutes: slices.select { |s| s[:night_diff] }.sum { |s| s[:minutes] },
      holiday_minutes: slices.select { |s| s[:holiday] }.sum { |s| s[:minutes] },
      slices: slices
    }
  end
end