require_relative 'spec_helper'

describe TwitterConnector do
  
  # Create a new instance of TwitterConnector that we can easily access
  let(:twitter) { TwitterConnector.new 52.4744895, -1.4845575, 5.2 }
  subject{ twitter }

  # Check the class variables get set correctly
  context 'initial conditions' do
    its(:lat)    { should == 52.4744895 }
    its(:lng)    { should == -1.4845575 }
    its(:radius) { should == 5.2 }
  end

  # Check the bounding box is generated correctly
  context 'generateBoundingBox function' do

    context 'with valid input: 52.47, -1.48, 15' do
      subject { twitter.generateBoundingBox 52.47, -1.48, 15 }

      specify('bounding box should == -1.8359771880161577,52.25314522071962,-1.1240228119838427,52.686854779280395') { subject.should == "-1.8359771880161577,52.25314522071962,-1.1240228119838427,52.686854779280395" }
                                      
    end

    context 'with invalid input' do

      subject { twitter.generateBoundingBox 52.47, -1.48, -15 }
      specify('bounding box should == error') { subject.should == "error" }

    end

  end

  context 'validateLocation function' do

    before { twitter.generateBoundingBox 52.47, -1.48, 15 }

    context 'with a location inside the bounding box' do
      subject { twitter.validateLocation 52.47168432976221, -1.474764347076416 }
      specify('coordinates 52.47... and -1.47... should be inside the box') {subject.should be_true}
    end

    context 'with a location outside the bounding box' do
      subject { twitter.validateLocation 51.51280224425956, -0.1242828369140625 }
      specify('coordinates 51.51... and -0.12... should be outside the box') {subject.should be_false}
    end

  end




end