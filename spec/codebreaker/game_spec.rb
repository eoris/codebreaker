require 'spec_helper'

module Codebreaker
  describe Game do
    context "#start" do
      let(:game) { Game.new }
 
      before do
        game.start
      end
 
      it "saves secret code" do
        expect(game.instance_variable_get(:@secret_code)).not_to be_empty
      end
 
      it "saves 4 numbers secret code" do
        expect(game.secret_code.count).to eq 4
      end

      it "saves 4 numbers with Fixnum class" do
        expect(game.secret_code.each(&:class)).to contain_exactly(Fixnum, Fixnum, Fixnum, Fixnum)
      end
 
      it "saves secret code with numbers from 1 to 6" do
        expect(game.secret_code.join).not_to match(/[^1-6]+/)
      end

    end
  end
end
