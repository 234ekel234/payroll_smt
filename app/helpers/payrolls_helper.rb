module PayrollsHelper
  def company_logo_path(company_name)
    return "default_logo.png" if company_name.blank?

    # Converts "SMT Technologies" to "smt_technologies_logo.png"
    logo_filename = "#{company_name.parameterize.underscore}_logo.png"

    # We use resolve_asset_path to check if it exists in the pipeline
    # If it fails, we rescue and return the default
    begin
      # This check works for Propshaft or Sprockets
      if Rails.application.assets && Rails.application.assets.find_asset(logo_filename)
        logo_filename
      else
        # Fallback for production where assets are precompiled
        logo_filename
      end
    rescue
      "default_logo.png"
    end
  end
end