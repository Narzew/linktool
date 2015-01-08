require 'open-uri'

module LinkTool

	def self.analyze_links_t(site,sitename,file)
		sitedata = lambda{open(site){|f| return f.read }}.call
		links = []
		x = sitedata.split("href=")
		size = x.size
		size.times{|y|
			z = x[y].split(">")[0]
			next if (z[0].to_s)[0] != "\""
			r = z.to_s.gsub("http://","start").gsub("\"","")
			if r =~ /\Astart/
				link = "#{z}".gsub("\"","")
			else
				link = "#{sitename}/#{z}".gsub("\"","")
			end
			links << link unless links.include?(link)
		}
		File.open(file,'wb'){|f| links.each{|x| f.write(x+"\n") }}
		return links
	end

	def self.download_links_t(file,sitename="")
		links = lambda{File.open(file,'rb'){|f |return f.read}}.call
		downcount = [0,0]
		links.each_line{|x|
			downcount[1] += 1
			ok = 1
			lambda{ open(x){|s| File.open(name, "wb"){|f| f.write(s.read)}}}.call rescue ok = 0
			name = x.gsub(sitename,"").gsub("http://","").gsub("/", "\\")
			x = x.gsub("\n","")
			name = name.gsub("\n","")
			if ok == 0
				print "[#{downcount[0]}/#{downcount[1]}] #{x} failed.\n"
			else
				downcount[0] += 1
				print "[#{downcount[0]}/#{downcount[1]}] #{name} (#{x}) downloaded.\n"
	
			end
		}
		print "[#{downcount[0]}/#{downcount[1]}] files downloaded.\n"
	end

	def self.analyze_and_download_t(site,sitename)
		sitedata = lambda{open(site){|f| return f.read }}.call
		links = []
		x = sitedata.split("href=")
		size = x.size
		size.times{|y|
			z = x[y].split(">")[0]
			next if (z[0].to_s)[0] != "\""
			r = z.to_s.gsub("http://","start").gsub("\"","")
			if r =~ /\Astart/
				link = "#{z}".gsub("\"","")
			else
				link = "#{sitename}/#{z}".gsub("\"","")
			end
			links << link unless links.include?(link)
		}
		downcount = [0,0]
		links.each{|x|
			downcount[1] += 1
			ok = 1
			lambda{ open(x){|s| File.open(name, "wb"){|f| f.write(s.read)}}}.call rescue ok = 0
			name = x.gsub(sitename,"").gsub("http://","").gsub("/", "\\")
			x = x.gsub("\n","")
			name = name.gsub("\n","")
			name[0] = ""
			if ok == 0
				print "[#{downcount[0]}/#{downcount[1]}] #{x} failed.\n"
			else
				downcount[0] += 1
				print "[#{downcount[0]}/#{downcount[1]}] #{name} (#{x}) downloaded.\n"
	
			end
		}
		print "[#{downcount[0]}/#{downcount[1]}] files downloaded.\n"
	end

	def self.analyze_links
		print "Enter the site you want download links from (for ex. http://mysite.com/download.html): "
		site = $stdin.gets.chomp!
		print "Enter the site base (for ex. http://misite.com): "
		sitename = $stdin.gets.chomp!
		print "Enter file name: "
		file = $stdin.gets.chomp!
		LinkTool.analyze_links_t(site,sitename,file)
	end

	def self.download_links
		print "Enter the file name: "
		file = $stdin.gets_chomp!
		print "Enter the site for names or leave blank: "
		site = $stdin.gets.chomp!
		LinkTool.download_links_t(file,site)
	end

	def self.analyze_and_download
		print "Enter the site you want download links from (for ex. http://mysite.com/download.html): "
		site = $stdin.gets.chomp!
		print "Enter the site base (for ex. http://misite.com): "
		sitename = $stdin.gets.chomp!
		LinkTool.analyze_and_download_t(site,sitename)
	end

	def self.start
		LinkTool.print_header
		if ARGV[0] == nil
			LinkTool.start_interactive
		else
			LinkTool.start_terminal
		end
	end

	def self.print_header
		print "**LinkTool Web Link Analyzer and Downloader\n**by Narzew\n**16.11.2013\n**v 1.1\n**All rights reserved.\n\n"
	end

	def self.start_interactive
		print "0 - analyze links on the site and save to a file\n"
		print "1 - download links contained in a file\n"
		print "2 - analyze and download links on the site\n"
		mode = $stdin.gets.chomp!.to_i
		case mode
		when 0 then LinkTool.analyze_links
		when 1 then LinkTool.download_links
		when 2 then LinkTool.analyze_and_download
		else
			print "Enter the correct choice.\n"
			exit
		end
	end

	def self.start_terminal
		if ARGV[0].to_s == "0" || ARGV[0].to_s == "a"
			LinkTool.analyze_links_t(ARGV[1],ARGV[2],ARGV[3])
		elsif ARGV[0].to_s == "1" || ARGV[0].to_s == "d"
			if ARGV.size == 2
				LinkTool.download_links_t(ARGV[1])
			else
				LinkTool.download_links_t(ARGV[1],ARGV[2])
			end
		elsif ARGV[0].to_s == "2" || ARGV[0].to_s == "ad"
			LinkTool.analyze_and_download_t(ARGV[1],ARGV[2])
		end
	end
		
end

begin
	LinkTool.start
rescue => e
	print "Error: #{e}\n"
	$stdin.gets
	exit
end
