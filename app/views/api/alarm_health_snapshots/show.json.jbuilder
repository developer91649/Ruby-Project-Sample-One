json.key_format! camelize: :lower

json.array! @snapshot do |history|
  history.keys.each do |k|
    json.set! k, history[k]
  end
end
