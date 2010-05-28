require 'slice_template'

class DocxBuilder
  def initialize(template_filename, template_dirname)
    @template_filename = template_filename
    @template_dirname = template_dirname
  end

  def build
    template = SliceTemplate.new(@template_filename);
    yield template
    build_docx(template.render)
  end

  private

  def build_docx(content)
    docx_content = nil
    in_temp_dir do |temp_dir|
      system("cp -r #{@template_dirname} #{temp_dir}/plan_report")
      open("#{temp_dir}/plan_report/word/document.xml", "w") do |file|
        file.write(content)
      end
      system("cd #{temp_dir}/plan_report; zip -r ../plan_report.docx *")
      docx_content = File.read("#{temp_dir}/plan_report.docx")
    end
    docx_content
  end

  def in_temp_dir
    temp_dir = "/tmp/docx_#{Time.now.to_f.to_s}"
    Dir.mkdir(temp_dir)
    yield(temp_dir)
    system("rm -Rf #{temp_dir}")
  end
end


