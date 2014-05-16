class PriorityFilter < Filter
  def pass?(notice)
    result = matches(notice).compact.any?
    up_count_for_match if result
    result
  end
end
