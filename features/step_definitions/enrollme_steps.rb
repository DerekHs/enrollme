Given /^PENDING: .*$/ do
  pending
end

Given /^the allowed team size is (\d+)-(\d+)$/ do |min,max|
  Option.first.update_attributes!(:minimum_team_size => min,
    :maximum_team_size => max)
end

Given /^the allowed team size is (\d+)$/ do |num|
  Option.first.update_attributes!(:minimum_team_size => num,
    :maximum_team_size => num)
end

When /^I fill in "([^"]*)" with the correct password$/ do | field |
  fill_in(field, :with => ENV["ADMIN_DELETE_DATA_PASSWORD"])
end

Given /^I log in as an admin with email "([^"]*)"$/ do | email |
  mock_auth_hash(email)
  click_button "log_in"
end

Given /^I log in as a user with email "([^"]*)"$/ do | email |
  mock_auth_hash(email)
  click_button "log_in"
end

And /^I log out$/ do
  step %Q{I follow "Logout"}
end

When /^I remove "([^"]*)"$/ do | user |
  step %Q{I press "remove_#{user}"}
end

When /^I leave my team$/ do
  step %Q{I press "leave_team"}
end

And /^I join a team with passcode "([^"]*)"$/ do | passcode |
  step %Q{I fill in "team_hash" with "#{passcode}"}
  step %Q{I press "Join"}
end

Given(/^the team with passcode "([^"]*)" is approved with discussion number "([^"]*)"$/) do |passcode, number|
  Team.find_by_passcode(passcode).approve_with_discussion(Discussion.find_by_number(number).id)
end

Given(/^the team with passcode "([^"]*)" is submitted with discussion numbers "([^"]*)", "([^"]*)", and "([^"]*)"$/) do |passcode, d1, d2, d3|
  s = Submission.create!(:disc1id => Discussion.find_by_number(d1).id, :disc2id => Discussion.find_by_number(d2).id, :disc3id => Discussion.find_by_number(d3).id)
  Team.find_by_passcode(passcode).add_submission(s.id)
end

And /^the team with passcode "(.*)" is submitted$/ do |passcode|
  s = Submission.create(:disc1id => 1, :disc2id => 2, :disc3id => 3)
  Team.find_by(passcode: passcode).add_submission(1)
end

And /^the team with passcode "(.*)" is (not)? submitted$/ do | passcode, negate |
  Team.find_by(passcode: passcode).update(:submitted => false)
end

And /^the team with passcode "([^"]*)" is not approved$/ do | passcode |
  Team.find_by_passcode(passcode).update(:approved => false)
end

And /^my team is submitted$/ do
  Submission.create!(:disc1id => 1, :disc2id => 1, :disc3id => 1, :team => @team)
  @team.add_submission(1)
end

And /^the team with passcode "([^"]*)" should be (.*)$/ do | passcode, status |
  expect(Team.find_by_passcode(passcode).send(status)).to be_truthy
end

And /^the team with passcode "([^"]*)" should not be (.*)$/ do | passcode, status |
  expect(Team.find_by_passcode(passcode).send(status)).to be_falsy
end


Then /^the "([^"]*)" drop-down should contain the option "(.*)"$/ do |dropdown, text|
  expect(page).to have_select(dropdown, :options => [text])
end

# Note: use "0" as team to indicate that this student isn't on a team yet
Given /^the following users exist$/ do |table|
  table.rows.each do |name, email, team_passcode, major, sid, waitlisted|
    next if name == "name" # skipping table header
    @team = Team.where(:passcode => team_passcode).first
    if team_passcode != "0"
      @team = Team.create(:approved => false, :submitted => false, :passcode => team_passcode, :waitlisted => true) if @team.nil?
      @user = User.create(:team => @team, :major => major, :name => name, :email => email, :sid => sid, :waitlisted => true)
      @team.update_waitlist
      schedule = Schedule.create(:user => @user)
      skill_set = SkillSet.create(:user => @user, :ruby_on_rails => 1, :other_backend => 0, :frontend => 1, :ui_design => 0, :team_management => 1)
    else
      @user = User.create(:team => nil, :major => major, :name => name, :email => email, :sid => sid, :waitlisted => true)
      schedule = Schedule.create(:user => @user)
      skill_set = SkillSet.create(:user => @user, :ruby_on_rails => 1, :other_backend => 0, :frontend => 1, :ui_design => 0, :team_management => 1)
    end
  end
end

Given /^the following discussions exist$/ do |table|
  table.rows.each do |number, time, day, capacity, seats_open|
    next if number == :number # skipping table header
    Discussion.create!(:number => number.to_i, :time => time, :day => day, :capacity => capacity.to_i)
  end
end

Then /^(?:|I )should not be on (.+)$/ do |page_name|
  current_path = URI.parse(current_url).path
  if current_path.respond_to? :should
    current_path.should_not == path_to(page_name)
  else
    assert_not_equal path_to(page_name), current_path
  end
end


Then /^byebug$/ do
  byebug
end

Then /^print page body$/ do
  puts page.body
end

Then /^save and open page$/ do
  save_and_open_page
end

Then /^screenshot and open image$/ do
  Capybara::Screenshot.screenshot_and_open_image
end

Then /^I should see the "([^"]*)" button/ do |name|
  should have_button name
end

Then /^I should not see the "([^"]*)" button/ do |name|
  should have_no_button name
end


Given /^the following admins exist$/ do |table|
  table.rows.each do |name, email, superadmin|
    next if name == "name" # skipping table header
    Admin.create!(:name => name, :email => email, :superadmin => superadmin == "true" ? true : false)
  end
end

Then /^I should have downloaded a team information file$/ do
   page.response_headers['Content-Disposition'].should include("team_info.csv")
end

Then(/^the team with passcode "([^"]*)" should not exist$/) do |passcode|
  Team.where(:passcode => passcode).length.should eq 0
end

Then(/^the team with ccn "([^"]*)", day "([^"]*)", time "([^"]*)", and capacity "([^"]*)" should exist$/) do |ccn, day, time, capacity|
  Discussion.where(:number => ccn, :day => day, :time => time, :capacity => capacity).length.should eq 1
end

Then /^"([^']*?)" should receive (\d+) emails?$/ do |address, n|
  unread_emails_for(address).size.should == n.to_i
end

When(/^I fill in "([^"]*)" with API\['ADMIN_DELETE_DATA_PASSWORD'\]$/) do |field|
  fill_in(field, :with => ENV["ADMIN_DELETE_DATA_PASSWORD"])
end

Then(/^the "([^"]*)" radio button should be checked$/) do |radio_button_name|
  expect(find_field(radio_button_name)).to be_checked
end

Then(/^the "([^"]*)" radio button should not be checked$/) do |radio_button_name|
  expect(find_field(radio_button_name)).to_not be_checked
end

And /team "([^']*?)" has (\d*) pending requests?/ do |pass, n|
  @team = Team.where(:passcode => pass).first
  #Stub pending requests function?
  @team.pending_requests
end

And /team "([^']*?)" is (not )?declared/ do |pass, no|
  @team = Team.where(:passcode => pass).first
  if no
    @team.declared = "Yes"
  else
    @team.declared = "No"
  end
end

Given /^I press the "([^"]*)" button on the same row as "([^"]*)"$/ do |req, name|
    page.find('tr', text: name).click_link(req)
end

Given /^I press the "([^"]*)" button on the same div as the team with passcode "([^"]*)"$/ do |req, passcode|
   @team = Team.where(passcode: passcode).first
   click_link("#{req}[#{@team.id}]")
end


And /^"(.*)" has a team id$/ do |name|
  expect(User.find_by(name: name).team_id.nil?).to be false
end


