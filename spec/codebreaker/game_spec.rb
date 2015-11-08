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
        expect(game.send(:secret_code).count).to eq 4
      end
 
      it "saves secret code with numbers from 1 to 6" do
        expect(game.send(:secret_code).join).not_to match(/[0789]/)
        # 4.times { |i| expect(game.secret_code[i].to_s).to match(/[1-6]/) }
      end
    end
  end
end