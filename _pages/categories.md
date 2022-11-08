---
layout: page
permalink: /categories/
title: Categories
description: All the posts are sorted based on their category.
no_article_rev: true
---

<div class="categories-page">
  {% for category in site.categories reversed %}
  <div class="archive-group rev">
    {% capture category_name %}{{ category | first }}{% endcapture %}
    <a name="{{ category_name | slugify }}"></a>
    <div>
      <h3 class="category-head custom-category-head">{{ category_name }}</h3>
      {% if site.categories[category_name].size > 3 %}
        <a class="nostyle" href="{{ site.baseurl }}/categories/{{ category_name | downcase | replace: ' ', '-' }}">
          <div class="custom-category-more">
            <span>More &raquo;</span>
          </div>
        </a>
      {% endif %}
    </div>
    <div class="row">
      {% for post in site.categories[category_name] limit: 3 %}
      <div class="col-md-4">
        <a class="nostyle" href="{{ site.baseurl }}{{ post.url }}">
          <div class="cards">
            <div class="image" style="background-image: url({{site.baseurl}}{{post.image}})"></div>
            <p class="text-center">{{post.title}}</p>
          </div>
        </a>
      </div>
      {% endfor %}
    </div>
  </div>
  {% endfor %}
</div>