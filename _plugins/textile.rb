module Jekyll
  class Nohassle < Generator
    safe false
    @@folder = '_textile

    def generate(site)
        now = Date.today.strftime("%Y-%m-%d") 
      @files = Dir["#{@@folder}/*"]
      @files.each_with_index { |f,i| 
        old_text = File.read(f)
        n = f.dup
        n[0..@@folder.length] = ""
        n = n.slice(0..-4)
        File.open("temp.textile", 'w') do |file|

          file.write("---\nlayout: post\ncover: 'assets/images/cover_gen.jpg'\ntitle: #{n}\ndate: #{now}\ntags: generic\nsubclass: 'post tag-test tag-content'\ncategories: 'commacen'\nnavigation: True\nlogo: 'assets/images/cata.png'\n---\n")
          file.write("h2. {n}\n")
          file.write(old_text)
        end

        File.delete(f)

        File.rename('temp.textile', f)

        # Renaming files with appropriate date
        File.rename(f, "_posts/#{now}-#{File.basename(f.gsub(/\s+/, '-'))}") 
      }
    end
  end
end
