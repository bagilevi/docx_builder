require 'docx_builder'


plan_struct = Struct.new(:name, :areas, :goals_by_area, :objectives_by_goal)
area_struct = Struct.new(:description, :id)
goal_struct = Struct.new(:description, :id)
objective_struct = Struct.new(:description)
@plan = plan_struct.new
@plan.name = 'Business Plan for 2011'
@plan.areas = [area_struct.new('Software Development', 1), area_struct.new('Cooking', 2)]
@plan.goals_by_area = {
        1 => [ goal_struct.new('Create a new app', 1), goal_struct.new('Create another app', 2)],
        2 => [ goal_struct.new('Make a new recipe', 3), goal_struct.new('Open a restaurant', 4)],
}
@plan.objectives_by_goal = {
        1 => [ objective_struct.new('It should be interesting'), objective_struct.new('It should be simple') ],
        2 => [ objective_struct.new('It should be revolutionary'), objective_struct.new('It should be unique') ],
        3 => [ objective_struct.new('Make a unique recipe'), objective_struct.new('Make a tasty recipe') ],
        4 => [ objective_struct.new('Serve high quality food'), objective_struct.new('Make it cheap') ],
}


file_path = "#{File.dirname(__FILE__)}/example/plan_report_template.xml"
dir_path = "#{File.dirname(__FILE__)}/example/plan_report_template"

report = DocxBuilder.new(file_path, dir_path).build do |template|

  template['head']['Plan Name'] = @plan.name
  template['area'] =
    @plan.areas.map do |area|

      area_slice = template['area'].clone
      area_slice['Area Name'] = area.description
      area_slice['goal'] =
        @plan.goals_by_area[area.id].map do |goal|

          goal_slice = template['goal'].clone
          goal_slice['Goal Name'] = goal.description
          goal_slice['objective'] =
            @plan.objectives_by_goal[goal.id].map do |objective|
              objective_slice = template['objective'].clone
              objective_slice['Objective Name'] = objective.description
              objective_slice
            end
          goal_slice
        end
      area_slice
    end
end


open("example.docx", "w") { |file| file.write(report) }

# ... or in a Rails controller:
# response.headers['Content-disposition'] = 'attachment; filename=plan_report.docx'
# render :text => report, :content_type => 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
