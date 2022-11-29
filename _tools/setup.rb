require 'yaml'

### 경로 설정 ###

root_path = "."
if ARGV.length >= 1
	root_path = ARGV[0]
end

posts_path = File.join(root_path, "_posts")
tools_path = File.join(root_path, "_tools")
categories_path = File.join(root_path, "_categories")
portfolio_path = File.join(root_path, "_portfolio")
data_path = File.join(root_path, "_data")

### 카테고리별 포스트 분류 ###

files = Dir.entries(posts_path)
posts = Array.new
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

template = File.read(File.join(tools_path, "category.html"))

categories.each { |category|
	category_url = category.downcase.gsub(" ", "-")
	page_count = (category_count[category] - 1) / 5 + 1

	for i in 1..page_count
		html = template

		if i == 1
			html = html.gsub("{$link}", category_url)
			file_name = File.join(categories_path, category_url + ".html")
		else
			html = html.gsub("{$link}", category_url + "/page" + i.to_s)
			file_name = File.join(categories_path, category_url + "_page" + i.to_s + ".html")
		end
		
		html = html.gsub("{$category}", category)
		html = html.gsub("{$page_index}", i.to_s)
		html = html.gsub("{$total_page}", page_count.to_s)

		File.open(file_name, "w") { |f| f.write html }
	end
}

File.open(File.join(data_path, "categories.yml"), "w") { |f| f.write categories.to_yaml }

### 포트폴리오 - 전체 데이터 ###

portfolio_data = Array.new
portfolio_projects = Array.new
categories = YAML.load_file(File.join(data_path, "portfolio_categories.yml"))

categories.each { |category|
	category_url = category.downcase.gsub(" ", "-")
	category_path = File.join(portfolio_path, category_url)

	category_data = Hash.new
	category_data["category"] = category
	category_data["link"] = "/portfolio/" + category_url
	category_data["projects"] = Array.new
	portfolio_data.push(category_data)

	files = Dir.entries(category_path)
	files.each { |file|
		if File.extname(file) == ".md"
			yaml = YAML.load_file(File.join(category_path, file))

			data = Hash.new
			data["link"] = "/portfolio/" + category_url + "/" + File.basename(file, ".md")
			data["title"] = yaml["title"]
			data["date"] = yaml["date"]
			data["image"] = yaml["image"]
			data["tag"] = yaml["tag"]

			category_data["projects"].push(data)
			portfolio_projects.push(data)
		end
	}

	category_data["projects"].sort! { |x, y| y["date"] <=> x["date"] }
}
portfolio_projects.sort! { |x, y| y["date"] <=> x["date"] }

File.open(File.join(data_path, "portfolio.yml"), "w") { |f| f.write portfolio_data.to_yaml }

### 포트폴리오 - 카테고리 페이지 ###

template = File.read(File.join(tools_path, "portfolio_category.html"))
for i in 0..(portfolio_data.count-1) do
	html = template
	html = html.gsub("{$category}", portfolio_data[i]["category"])
	html = html.gsub("{$link}", portfolio_data[i]["link"])
	html = html.gsub("{$index}", i.to_s)
	File.open(File.join(portfolio_path, portfolio_data[i]["category"] + ".html"), "w") { |f| f.write html }
end

### 포트폴리오 - 태그 데이터 ###

portfolio_tag_hash = Hash.new
portfolio_tags = Array.new

portfolio_projects.each { |project|
	project["tag"].each { |tag|
		if not portfolio_tag_hash.key?(tag)
			portfolio_tag_hash[tag] = portfolio_tags.count
			tag_data = Hash.new
			tag_data["tag"] = tag
			tag_data["projects"] = Array.new
			portfolio_tags.push(tag_data)
		end

		portfolio_tags[portfolio_tag_hash[tag]]["projects"].push(project)
	}
}

File.open(File.join(data_path, "portfolio_tags.yml"), "w") { |f| f.write portfolio_tags.to_yaml }

### 포트폴리오 - 태그 페이지 ###

template = File.read(File.join(tools_path, "portfolio_tag.html"))
for i in 0..(portfolio_tags.count-1) do
	tag_url = portfolio_tags[i]["tag"].downcase.gsub(" ", "-")
	html = template
	html = html.gsub("{$tag}", portfolio_tags[i]["tag"])
	html = html.gsub("{$tag_url}", tag_url)
	html = html.gsub("{$index}", i.to_s)
	File.open(File.join(portfolio_path, "tag-" + portfolio_tags[i]["tag"] + ".html"), "w") { |f| f.write html }
end
