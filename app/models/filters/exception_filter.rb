class ExceptionFilter < Filter
  def pass?(notice)
    result = matches(notice).compact.any? { |m| m == false }
    up_count_for_match unless result
    result
  end
end
