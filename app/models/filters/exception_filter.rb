class ExceptionFilter < Filter
  def pass?(notice)
    matches(notice).compact.any? { |m| m == false }
  end
end
