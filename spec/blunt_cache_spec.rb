require 'spec_helper'

describe BluntCache do

  class MyCache < BluntCache
  end

  class ShortCache < BluntCache
    @expire_default = 0.1
  end

  [BluntCache, MyCache, ShortCache].each do |c|
    context '#{c.name}' do
      context 'set' do
        it { expect(c.set("1", "1_val")).to eq "1_val" }
      end

      context 'get' do
        before(:all) { c.set("1", "1_val") }

        it { expect(c.get("1")).to eq "1_val" }

        it 'returns previous set value' do
          c.set("1", "1_val_2")
          expect(result = c.get("1")).to eq "1_val_2"
        end

        it 'returns nil if not set' do
          expect(c.get("2")).to eq nil
        end
      end

      context 'get with expiration' do
        before(:each) { c.set("3", "3_val", :expire => 0.1) }

        it { expect(c.get("3")).to eq "3_val" }

        it 'returns value after short sleep' do
          sleep(0.09)
          expect(c.get("3")).to eq "3_val"
        end

        it 'returns nil after long sleep' do
          sleep(0.11)
          expect(c.get("3")).to eq nil
        end
      end

      context 'key?' do
        before(:all) { c.set("k1", "k1_val") }

        it { expect(c.key?("k1")).to eq true }
        it 'returns false if not set' do
          expect(c.key?("k2")).to eq false
        end
      end

      context 'key? with expiration' do
        before(:each) { c.set("k3", "k3_val", :expire => 0.1) }

        it { expect(c.key?("k3")).to eq true }

        it 'returns true after short sleep' do
          sleep(0.09)
          expect(c.key?("k3")).to eq true
        end

        it 'returns false after long sleep' do
          sleep(0.11)
          expect(c.key?("k3")).to eq false
        end
      end

      context 'fetch' do
        it 'executes block for a first time' do
          executed = :not_executed
          expect(c.fetch("4-0") { executed = :executed }).to eq :executed
          expect(executed).to eq :executed
        end

        it 'sets value from block' do
          expect(c.get("4")).to eq nil #pre-check
          expect(c.fetch("4") { "4_val" }).to eq "4_val"
        end

        it 'doesn\'t execute block for a second time' do
          expect(c.fetch("4-1") { :executed_first }).to eq :executed_first
          executed = :not_executed
          expect(c.fetch("4-1") { executed = :executed_second }).to eq :executed_first
          expect(executed).to eq :not_executed
        end
      end

      context 'fetch with experation' do
        it 'recieves :expire' do
          expect( c.fetch("6", :expire => 0.1) { "6_val" } ).to eq "6_val"
        end

        it 'doesn\'t execute block for a second time' do
          expect(c.fetch("6-1", :expire => 0.1) { :executed_first }).to eq :executed_first
          executed = :not_executed
          expect(c.fetch("6-1", :expire => 0.1) { executed = :executed_second }).to eq :executed_first
          expect(executed).to eq :not_executed
        end

        it 'doesn\'t execute block for a second time after short sleep' do
          expect(c.fetch("6-2", :expire => 0.1) { :executed_first }).to eq :executed_first
          executed = :not_executed
          sleep(0.09)
          expect(c.fetch("6-2", :expire => 0.1) { executed = :executed_second }).to eq :executed_first
          expect(executed).to eq :not_executed
        end

        it 'executes block for a second time after long sleep' do
          expect(c.fetch("6-3", :expire => 0.1) { :executed_first }).to eq :executed_first
          executed = :not_executed
          sleep(0.11)
          expect(c.fetch("6-3", :expire => 0.1) { executed = :executed_second }).to eq :executed_second
          expect(executed).to eq :executed_second
        end
      end

      context 'fetch with nil' do
        it 'doesn\'t re-executes for nil value' do
          execution_counter = 0
          expect(c.fetch("nill") { execution_counter+= 1; nil }).to eq nil
          expect(execution_counter).to eq 1
          expect(c.fetch("nill") { execution_counter+= 1; nil }).to eq nil
          expect(execution_counter).to eq 1
        end
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