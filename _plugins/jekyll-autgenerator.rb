module Jekyll

  # The AuthorIndex class creates a single author page for the specified author.
  class AuthorIndex < Page

    # Initializes a new AuthorIndex.
    #
    #  +base+         is the String path to the <source>.
    #  +author_dir+ is the String path between <source> and the author folder.
    #  +author+     is the author currently being processed.
    def initialize(site, base, author_dir, author)
      @site = site
      @base = base
      @dir  = author_dir
      @name = 'index.html'
      puts "author #{author} @dir #{author_dir}"
      self.process(@name)
      # Read the YAML data from the layout page.
      self.read_yaml(File.join(base, '_layouts'), 'author.html')
      self.data['author']    = author
      # Set the title for this page.
      title_prefix             = site.config['author_title_prefix'] || 'author: '
      self.data['title']       = "#{author}"
      # Set the meta-description for this page.
      meta_description_prefix  = site.config['author_meta_description_prefix'] || 'author: '
      self.data['description'] = "#{meta_description_prefix}#{author}"
    end

  end

  # The Site class is a built-in Jekyll class with access to global site config information.
  class Site

    # Creates an instance of AuthorIndex for each author page, renders it, and
    # writes the output to a file.
    #
    #  +author_dir+ is the String path to the author folder.
    #  +author+     is the author currently being processed.
    def write_author_index(author_dir, author)
      index = AuthorIndex.new(self, self.source, author_dir, author)
      index.render(self.layouts, site_payload)
      index.write(self.dest)
      # Record the fact that this page has been added, otherwise Site::cleanup will remove it.
      self.pages << index

    end

    # Loops through the list of author pages and processes each one.
    def write_author_indexes
      author_dirs_written = []

      if self.layouts.key? 'author_index'
        dir = self.config['author_dir'] || 'authors'
        self.posts.each do |post|
          post_authors = post.data["author"]
          if String.try_convert(post_authors)
               post_authors = [ post_authors ]
          end
          post_authors.each do |author|
            author_dir = File.join(dir, author.downcase.gsub(' ', '-'))
            if not author_dirs_written.include?(author_dir)
              author_dirs_written.push(author_dir)
              self.write_author_index(author_dir, author)
            end
          end unless post_authors.nil?
        end
      # Throw an exception if the layout couldn't be found.
      else
        throw "No 'author_index' layout found."
      end
    end

  end

  class AuthorsGenerator < Generator
  
    safe true

    def generate(site)
      site.write_author_indexes      
      site.categories.each do |category|
        build_subpages(site, "author", category)
      end
    end

    def build_subpages(site, type, posts) 
      posts[1] = posts[1].sort_by { |p| -p.date.to_f }     
      atomize(site, type, posts)
      paginate(site, type, posts)
    end

    def atomize(site, type, posts)
      path = "/authors/#{posts[0]}"
      atom = AtomPageAuthor.new(site, site.source, path, type, posts[0], posts[1])
      site.pages << atom
    end

    def paginate(site, type, posts)
      pages = Jekyll::Paginate::Pager.calculate_pages(posts[1], site.config['paginate'].to_i)
      (1..pages).each do |num_page|
        pager = Jekyll::Paginate::Pager.new(site, num_page, posts[1], pages)
        path = "/authors/#{posts[0]}"
        if num_page > 1
          path = path + "/page#{num_page}"
        end
        newpage = GroupSubPageAuthor.new(site, site.source, path, type, posts[0])
        newpage.pager = pager
        site.pages << newpage 

      end
    end
  end

  class GroupSubPageAuthor < Page
    def initialize(site, base, dir, type, val)
      @site = site
      @base = base
      @dir = dir
      @name = 'index.html'

      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), "author.html")
      self.data["grouptype"] = type
      self.data[type] = val
    end
  end
  
  class AtomPageAuthor < Page
    def initialize(site, base, dir, type, val, posts)
      @site = site
      @base = base
      @dir = dir
      @name = 'rss.xml'

      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), "author.xml")
      self.data[type] = val
      self.data["grouptype"] = type
      self.data["posts"] = posts[0..9]
    end
  end
end