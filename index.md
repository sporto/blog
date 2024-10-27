---
layout: default.liquid
title: Blog
---

{% for post in collections.posts.pages %}
[{{ post.published_date | date: "%Y-%m-%d" }} {{ post.title }}]({{ post.permalink }})
{% endfor %}
