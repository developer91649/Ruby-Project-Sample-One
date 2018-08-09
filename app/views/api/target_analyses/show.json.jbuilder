json.key_format! camelize: :lower

json.data(@target_analysis["data"]) do |mparam|
  mparam.keys.each do |k|
    json.set! k, mparam[k]
  end
end

json.locomotive(@target_analysis["locomotive"])
