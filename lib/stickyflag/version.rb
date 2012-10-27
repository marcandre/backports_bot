# -*- encoding : utf-8 -*-

class StickyFlag
  module Version
    NUMBERS = [
      MAJOR = 0,
      MINOR = 1,
      BUILD = 0
    ]
  end
  VERSION = Version::NUMBERS.join('.')
end
