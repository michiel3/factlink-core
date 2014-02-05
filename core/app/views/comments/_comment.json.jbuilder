json.id           comment.id
json.created_at   comment.created_at
json.created_by do |json|
  json.partial! 'users/user_partial', user: comment.created_by
end
json.type         comment.type #rename: "type"

json.formatted_comment_content comment.formatted_content

json.time_ago comment.time_ago

json.tally comment.tally

json.is_deletable comment.deletable?

json.sub_comments_count comment.sub_comments_count
