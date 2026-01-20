# This ensures Pagy works nicely with Turbo and Search params
require 'pagy/extras/bootstrap'
require 'pagy/extras/overflow'

Pagy::DEFAULT[:overflow] = :last_page # If someone enters a huge page number, go to last page