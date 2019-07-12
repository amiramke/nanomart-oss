# you can buy just a few things at this nanomart

class Nanomart
  class NoSale < StandardError; end

  def initialize(logfile)
    @logfile = logfile
  end

  def sell_me(itm_type, prompter)
    itm = case itm_type
          when :beer
            Item::Beer.new(@logfile)
          when :whiskey
            Item::Whiskey.new(@logfile)
          when :cigarettes
            Item::Cigarettes.new(@logfile)
          when :cola
            Item::Cola.new(@logfile)
          when :canned_haggis
            Item::CannedHaggis.new(@logfile)
          else
            raise ArgumentError, "Don't know how to sell #{itm_type}"
          end

    itm.restrictions.each do |r|
      itm.try_purchase(r.check(prompter))
    end
    itm.log_sale
  end
end

module Restriction
  DRINKING_AGE = 21
  SMOKING_AGE = 18

  class DrinkingAge
    def check(prompter)
      prompter.get_age >= DRINKING_AGE
    end
  end

  class SmokingAge
    def check(prompter)
      prompter.get_age >= SMOKING_AGE
    end
  end

  class SundayBlueLaw
    def check(_prompter)
      # 0 is Sunday
      Time.now.wday != 0
    end
  end
end

class Item
  INVENTORY_LOG = 'inventory.log'

  def initialize(logfile)
    @logfile = logfile
  end

  def log_sale
    File.open(@logfile, 'a') do |f|
      f.write(name.to_s + "\n")
    end
  end

  def name
    self.
      class.
      to_s.
      sub(/^Item::/, '').
      downcase.
      to_sym
  end

  def try_purchase(success)
    if success
      return true
    else
      raise Nanomart::NoSale
    end
  end

  class Beer < Item
    def restrictions
      [Restriction::DrinkingAge.new]
    end
  end

  class Whiskey < Item
    # you can't sell hard liquor on Sundays for some reason
    def restrictions
      [
        Restriction::DrinkingAge.new,
        Restriction::SundayBlueLaw.new
      ]
    end
  end

  class Cigarettes < Item
    # you have to be of a certain age to buy tobacco
    def restrictions
      [Restriction::SmokingAge.new]
    end
  end

  class Cola < Item
    def restrictions
      []
    end
  end

  class CannedHaggis < Item
    # the common-case implementation of Item.name doesn't work here
    def name
      :canned_haggis
    end

    def restrictions
      []
    end
  end
end

