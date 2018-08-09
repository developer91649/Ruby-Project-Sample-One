jQuery ->
  # Conditional toggle for state field depending on user's saved country or
  # when the user changes the country. If United States is selected, show a select
  # dropdown, else show an input
  $('#user_state_input').hide()
  $statesSelect = $('select#user_state')
  selectedState = $('input#user_state').val()
  # save us states select list
  statesSelect = $('select#user_state').clone()
  $statesSelect.closest("#user_state_input").remove()
  selectedCountry = $('#user_country :selected').text()
  $stateField = $('#user_state_input .controls')
  if selectedCountry is "United States"
    $stateField.empty().append(statesSelect)
  else
    $stateField
      .empty()
      .append('<input id="user_state" maxlength="255" name="user[state]" type="text" value="'+selectedState+'">')
  $('#user_state_input').show()

  $('#user_country').change ->
    country = $('#user_country :selected').text()
    if country is "United States"
      $stateField.empty().append(statesSelect)
    else
      $stateField
        .empty()
        .append('<input id="user_state" maxlength="255" name="user[state]" type="text" value="">')