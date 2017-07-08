$(document).on 'turbolinks:load', ->
  $('body').on 'click', 'a.leave_team', (e) ->
    $('#leave_team_modal').modal('open')
    $('.leave_team_form').attr('action', 'team_users/' + e.target.id)
    $('#user_remove_id').val(e.target.id)
    return false

  $('.leave_team_form').on 'submit', (e) ->
    $.ajax e.target.action,
        type: 'DELETE'
        dataType: 'json',
        data: {team_id: $(".team_id").val()}
        success: (data, text, jqXHR) ->
          $('.user_' + $('#user_remove_id').val()).remove()
          Materialize.toast('Success leaving the team &nbsp;<b>:)</b>', 4000, 'green')
        error: (jqXHR, textStatus, errorThrown) ->
          Materialize.toast('Problem leaving the team &nbsp;<b>:(</b>', 4000, 'red')

    $('#leave_team_modal').modal('close')
    return false
