require 'spec_helper'

describe BluntCache do

  class MyCache < BluntCache
  end

  class ShortCache < BluntCache
    @expire_default = 0.1
  end

  [BluntCache, MyCache, ShortCache].each do |c|
    context '#{c.name}' do
      it 'stores data' do
        expect { c.set("1", "1_val") }.not_to raise_error
        result = nil
        expect { result = c.get("1") }.not_to raise_error
        expect(result).to eq "1_val"
        expect { c.set("1", "1_val_2") }.not_to raise_error
        expect { result = c.get("1") }.not_to raise_error
        expect(result).to eq "1_val_2"
      end

      it 'returns nil on no data' do
        result = "value"
        expect { result = c.get("2") }.not_to raise_error
        expect(result).to eq nil
      end

      it 'returns value before expiration and nil after expiration' do
        expect { c.set("3", "3_val", expire: 0.1) }.not_to raise_error
        result = nil
        expect { result = c.get("3") }.not_to raise_error
        expect(result).to eq "3_val"
        sleep(0.09)
        expect { result = c.get("3") }.not_to raise_error
        expect(result).to eq "3_val"
        sleep(0.02)
        expect { result = c.get("3") }.not_to raise_error
        expect(result).to eq nil
      end

      it 'evals block in fetch if cache not set' do
        expect(c.get("4")).to eq nil
        result = nil
        expect { result = c.fetch("4") do "4_val" end }.not_to raise_error
        expect(result).to eq "4_val"
        expect(c.get("4")).to eq "4_val"
        expect { result = c.fetch("4") do "4_val_2" end }.not_to raise_error
        expect(result).to eq "4_val"
      end

      it 'returns value before expiration and re-executes block after expiration (fetch)' do
        result = nil
        expect { result = c.fetch "6", expire: 0.1 do "6_val" end }.not_to raise_error
        expect(result).to eq "6_val"
        expect { result = c.fetch "6" do "6_val_2" end }.not_to raise_error
        expect(result).to eq "6_val"
        sleep(0.11)
        expect { result = c.fetch "6" do "6_val_3" end }.not_to raise_error
        expect(result).to eq "6_val_3"
      end
    end
  end

  it 'can be namespaced by inheritance' do
    expect { result = MyCache.set "7", "7_val" }.not_to raise_error
    expect(BluntCache.get "7").to eq nil
    expect(ShortCache.get "7").to eq nil
    expect(MyCache.get "7").to eq "7_val"
  end

  it 'uses overrided @expire_default when inherited' do
    expect { result = ShortCache.set "8", "8_val" }.not_to raise_error
    expect(ShortCache.get "8").to eq "8_val"
    sleep(0.11)
    expect(ShortCache.get "8").to eq nil
  end

end