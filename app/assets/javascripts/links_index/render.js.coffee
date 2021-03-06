container = '
<div class="panel panel-default" id="panel-{{id}}">
  <div class="panel-heading">
    <a href="links/{{id}}" target="_blank"><strong>{{title}}</strong></a></a>
    <a data-toggle="collapse" data-parent="#panel-{{id}}" href="#container-{{id}}" class="glyphicon glyphicon-chevron-down collapse-btn"></a>
  </div>
  <div class="panel-collapse collapse in" id="container-{{id}}">
    <div class="panel-body" id="{{from}}"></div>
  </div>
</div>'

template = '
<div class="col-sm-4 feed">
  <div class="panel panel-default panel-small">
    <div class="panel-heading">{{&title}}</div>
    <div class="panel-body">{{&thumbimage}}{{&description}}</div>
  </div>
</div>'

root = exports ? this
root.renderize = ->
  $.getJSON '/index.json', (data) ->
    return if data.length == 0

    for i, link of data
      continue if link.feeds.length == 0

      id = data[i].title.replace(/\W/g, '')
      $('#feeds').append Mustache.render(container, { id: data[i].id, from: id, title: data[i].title })

      feedsUrl = btoa link.feeds
      continue if feedsUrl.indexOf('aHR0c') == -1

      $.ajax "/feeds/#{feedsUrl}",
        type:     'GET'
        dataType: 'xml'
        async:    false
        success:  (feeds, status, jqXHR) ->
          $(feeds).find('item')[0..5].each ->
            el = $(this)

            _title       = el.find('title').text()
            _description = el.find('description').text()
            _link        = el.find('link').text()
            _thumbimage  = el.find('thumbimage').attr('url')
            _fullimage   = el.find('fullimage').attr('url')

            res = {
              title:      ->
                url = if link then link else '#'
                "<a href=\"#{_link}\" target=\"_blank\">#{_title}</a>"
              thumbimage: ->
                if _thumbimage
                  url = if _fullimage then _fullimage else '#'
                  "<a href=\"#{url}\" target=\"_blank\"><img src=\"#{_thumbimage}\" class=\"feedThumb\"></a>"
              description:  _description
            }

            $("##{id}").append Mustache.render(template, res)