require 'nanomart'

class Age9
  def get_age() 9 end
end

class Age19
  def get_age() 19 end
end

class Age99
  def get_age() 99 end
end

describe "making sure the customer is old enough" do
  context "when you're a kid" do
    before(:each) do
      @nanomart = Nanomart.new('/dev/null', Age9.new)
    end

    it "lets you buy cola and canned haggis" do
      expect { @nanomart.sell_me(:cola)          }.not_to raise_error
      expect { @nanomart.sell_me(:canned_haggis) }.not_to raise_error
    end

    it "stops you from buying anything age-restricted" do
      expect { @nanomart.sell_me(:beer)       }.to raise_error(Nanomart::NoSale)
      expect { @nanomart.sell_me(:whiskey)    }.to raise_error(Nanomart::NoSale)
      expect { @nanomart.sell_me(:cigarettes) }.to raise_error(Nanomart::NoSale)
    end
  end

  context "when you're a newly-minted adult" do
    before(:each) do
      @nanomart = Nanomart.new('/dev/null', Age19.new)
    end

    it "lets you buy cola, canned haggis, and cigarettes (to hide the taste of the haggis)" do
      expect { @nanomart.sell_me(:cola)          }.not_to raise_error
      expect { @nanomart.sell_me(:canned_haggis) }.not_to raise_error
      expect { @nanomart.sell_me(:cigarettes)    }.not_to raise_error
    end

    it "stops you from buying anything age-restricted" do
      expect { @nanomart.sell_me(:beer)       }.to raise_error(Nanomart::NoSale)
      expect { @nanomart.sell_me(:whiskey)    }.to raise_error(Nanomart::NoSale)
    end
  end

  context "when you're an old fogey on Thursday" do
    before(:each) do
      @nanomart = Nanomart.new('/dev/null', Age99.new)
      allow(Time).to receive(:now).and_return(Time.local(2010, 8, 12, 12))  # Thursday Aug 12 2010 12:00
    end

    it "lets you buy everything" do
      expect { @nanomart.sell_me(:cola)          }.not_to raise_error
      expect { @nanomart.sell_me(:canned_haggis) }.not_to raise_error
      expect { @nanomart.sell_me(:cigarettes)    }.not_to raise_error
      expect { @nanomart.sell_me(:beer)          }.not_to raise_error
      expect { @nanomart.sell_me(:whiskey)       }.not_to raise_error
    end
  end

  context "when you're an old fogey on Sunday" do
    before(:each) do
      @nanomart = Nanomart.new('/dev/null', Age99.new)
      allow(Time).to receive(:now).and_return(Time.local(2010, 8, 15, 12))  # Sunday Aug 15 2010 12:00
    end

    it "stops you from buying hard alcohol" do
      expect { @nanomart.sell_me(:whiskey)       }.to raise_error(Nanomart::NoSale)
    end
  end
end

