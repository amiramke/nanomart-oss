# you can buy just a few things at this nanomart
require 'highline'

class Nanomart
  class NoSale < StandardError; end

  def initialize(logfile, prompter)
    @logfile, @prompter = logfile, prompter
  end

  def sell_me(itm_type)
    itm = case itm_type
          when :beer
            Item::Beer.new(@logfile, @prompter)
          when :whiskey
            Item::Whiskey.new(@logfile, @prompter)
          when :cigarettes
            Item::Cigarettes.new(@logfile, @prompter)
          when :cola
            Item::Cola.new(@logfile, @prompter)
          when :canned_haggis
            Item::CannedHaggis.new(@logfile, @prompter)
          else
            raise ArgumentError, "Don't know how to sell #{itm_type}"
          end

    raise ArgumentError, "#{itm_type} is not in stock" unless itm.is_in_inventory?("#{itm_type}")

    itm.rstrctns.each do |r|
      itm.try_purchase(r.is_allowed_purchase)
    end
    itm.log_sale
  end
end

class HighlinePrompter
  def get_age
    HighLine.new.ask('Age? ', Integer) # prompts for user's age, reads it in
  end
end


class Restriction
  DRINKING_AGE = 21
  SMOKING_AGE = 18

  def initialize(p)
    @prompter = p
  end

  class DrinkingAge < Restriction
    def is_allowed_purchase
      @prompter.get_age >= DRINKING_AGE
    end
  end

  class SmokingAge < Restriction
    def is_allowed_purchase
      @prompter.get_age >= SMOKING_AGE
    end
  end

  class SundayBlueLaw < Restriction
    def is_allowed_purchase
      # pp Time.now.wday
      # debugger
      Time.now.wday != 0      # 0 is Sunday
    end
  end
end

class Item
  INVENTORY_LOG = 'inventory.log'

  def initialize(logfile, prompter)
    @logfile, @prompter = logfile, prompter
  end

  def rstrctns
    []
  end

  def is_in_inventory(item_name)
    File.open('inventory.log', 'a') do |f|

    end
  end

  def log_sale
    File.open(@logfile, 'a') do |f|
      f.write(nam.to_s + "\n")
    end
  end

  def nam
    class_string = self.class.to_s
    short_class_string = class_string.sub(/^Item::/, '')
    lower_class_string = short_class_string.downcase
    class_sym = lower_class_string.to_sym
    class_sym
  end

  def try_purchase(success)
    raise Nanomart::NoSale unless success

    true
  end

  class Beer < Item
    def rstrctns
      [Restriction::DrinkingAge.new(@prompter)]
    end
  end

  class HardLiquor < Item
    # you can't sell hard liquor on Sundays for some reason
    def rstrctns
      [Restriction::DrinkingAge.new(@prompter), Restriction::SundayBlueLaw.new(@prompter)]
    end
  end

  class Cigarettes < Item
    # you have to be of a certain age to buy tobacco
    def rstrctns
      [Restriction::SmokingAge.new(@prompter)]
    end
  end

  class Pop < Item
  end

  class CannedHaggis < Item
    # the common-case implementation of Item.nam doesn't work here
    def nam
      :canned_haggis
    end
  end
end

