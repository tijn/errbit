class PriorityFilter < Filter
  def pass?(notice)
    matches(notice).compact.any?
  end
end
