# you can buy just a few things at this nanomart

class Nanomart < ActiveRecord
  class NoSale < StandardError; end

  def initialize(logfile, prompter)
    @logfile, @prompter = logfile, prompter
  end

  def sell_me(itm_type)
    itm_klass = case itm_type
          when :beer
            Item::Beer
          when :whiskey
            Item::Whiskey
          when :cigarettes
            Item::Cigarettes
          when :cola
            Item::Cola
          when :canned_haggis
            Item::CannedHaggis
          else
            raise ArgumentError, "Don't know how to sell #{itm_type}"
          end

    itm = itm_klass.new(@logfile, @prompter)

    itm.rstrctns.each do |r|
      itm.try_purchase(r.condition_success?)
    end
    itm.log_sale
  end
end

module Restriction

  class DrinkingAge
    DRINKING_AGE = 21
    def initialize(p)
      @prompter = p
    end

    def condition_success?
      age = @prompter.get_age
      if age >= DRINKING_AGE
        true
      else
        false
      end
    end
  end

  class SmokingAge
    SMOKING_AGE = 18

    def initialize(p)
      @prompter = p
    end

    def condition_success?
      age = @prompter.get_age
      if age >= SMOKING_AGE
        true
      else
        false
      end
    end
  end

  class SundayBlueLaw
    def initialize(p)
      @prompter = p
    end

    def condition_success?
      # pp Time.now.wday
      # debugger
      Time.now.wday != 0      # 0 is Sunday
    end
  end
end

class Prompter
  attr_accessor :age

  def initialize
    @age = age
  end
end

class Item
  INVENTORY_LOG = 'inventory.log'

  def initialize(logfile, prompter)
    @logfile, @prompter = logfile, prompter
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
    if success
      return true
    else
      raise Nanomart::NoSale
    end
  end

  Item.select(name: name).first.restrictions
  Restriction.select(name: name)

  class NanoM

  class Item < ActiveRecord
    has_and_belongs_to_many :restrictions
    belongs_to :nanomart
  end

  class Restriction < ActiveRecord
    has_and_belongs_to_many :items
  end

  class Beer < Item
    def rstrctns
      [Restriction::DrinkingAge.new(@prompter)]
    end
  end

  class Whiskey < Item
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

  class Cola < Item
    def rstrctns
      []
    end
  end

  class CannedHaggis < Item
    # the common-case implementation of Item.nam doesn't work here
    def nam
      :canned_haggis
    end

    def rstrctns
      []
    end
  end
end

