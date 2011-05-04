require 'spec_helper'

describe Propel::Propel do
  describe "#start" do
    before do
      @repository = Propel::GitRepository.new
    end
    
    it "should call pull on the repository with rebase when rebase is true" do
      propel = Propel::Propel.new(@repository, true)
      @repository.should_receive(:pull).with(true)

      propel.start
    end

    it "should call pull on the repository without rebase when rebase is false" do
      propel = Propel::Propel.new(@repository, false)
      @repository.should_receive(:pull).with(false).and_return(false)

      propel.start
    end

    it"should call rake if the pull passes" do
      propel = Propel::Propel.new(@repository, true)
      @repository.should_receive(:pull).and_return(true)
      propel.should_receive(:rake).and_return(false)

      propel.start
    end

    it "should not call rake if the pull fails" do
      propel = Propel::Propel.new(@repository, true)
      @repository.should_receive(:pull).and_return(false)
      propel.should_not_receive(:rake)

      propel.start
    end

    it"should call push if rake passes" do
      propel = Propel::Propel.new(@repository, true)
      @repository.should_receive(:pull).and_return(true)
      propel.should_receive(:rake).and_return(true)
      @repository.should_receive(:push)

      propel.start
    end

    it "should not call push if rake fails" do
      propel = Propel::Propel.new(@repository, true)
      @repository.should_receive(:pull).and_return(true)
      propel.should_receive(:rake).and_return(false)
      @repository.should_not_receive(:push)

      propel.start
    end    
  end
end