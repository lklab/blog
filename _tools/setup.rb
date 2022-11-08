require 'yaml'

posts_path = "../_posts"

files = Dir.entries(posts_path)
posts = Array.new()
files.each { |file|
	if File.extname(file) == ".md"
		posts.push(file)
	end
}

posts.sort! { |x, y| y <=> x }
categories = Array.new
category_count = Hash.new

posts.each { |post|
	data = YAML.load_file(File.join(posts_path, post))
	data["categories"].each { |category|
		if not categories.include?(category)
			categories.push(category)
		end

		if category_count.key?(category)
			category_count[category] = category_count[category] + 1
		else
			category_count[category] = 1
		end
	}
}

template = File.read("category.html")

categories.each { |category|
	category_url = category.downcase.gsub(" ", "-")
	page_count = (category_count[category] - 1) / 5 + 1

	for i in 1..page_count
		html = template

		if i == 1
	    	html = html.gsub("{$link}", category_url)
			file_name = "../_categories/" + category_url + ".html"
	    else
	    	html = html.gsub("{$link}", category_url + "/page" + i.to_s)
			file_name = "../_categories/" + category_url + "_page" + i.to_s + ".html"
	    end
	    
	    html = html.gsub("{$category}", category)
	    html = html.gsub("{$page_index}", i.to_s)
	    html = html.gsub("{$total_page}", page_count.to_s)

	    File.open(file_name, "w") { |f| f.write html }
	end
}
