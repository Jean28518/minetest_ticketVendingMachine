default.ticket_vending_machine_machine_position = {}
-- HERE YOU CAN DEFINE THE DESCRIPTION OF THE BUTTONS: Naa
local BUTTON1_TEXT = "20 Minutes"
local BUTTON2_TEXT = "2 Hours"
-- HERE YOU CAN DEFINE THE DURATION OF THE TICKETS IN SECONDS:
local BUTTON1_SECONDS = 20 * 60
local BUTTON2_SECONDS = 120 * 60
-- HERE YOU CAN DEFINE THE PRICE OF THE TICKETS:
local BUTTON1_PRICE = 5
local BUTTON2_PRICE = 20

minetest.register_node("ticket_vending_machine:machine", {
  description = "Ticket Vending Machine",
  tiles = {"machine_side.png",
      "machine_side.png",
      "machine_side.png",
      "machine_side.png",
      "machine_side.png",
      "machine_front.png"},
  is_ground_content = true,
  -- light_source = 10,
  groups = {dig_immediate=2},
  paramtype2 = "facedir",
  sounds = default.node_sound_stone_defaults(),

  on_rightclick = function(pos, node, player, itemstack, pointed_thing)
    -- Schreibe die eigene Position des Blockes in eine öffentliche Variable mit dem Namen des Spielernamens, welcher auf den Block zugegriffen hat
    ticket_vending_machine_show_spec(player)
  end
})

ticket_vending_machine_show_spec = function (player)
  local pmeta = player:get_meta()
  local string_expiring = "           You currently have no ticket."
  if pmeta:get_int("ticket_vending_machine:elapsed_time") - minetest.get_gametime() > 0 then
    string_expiring = "Your current ticket expires in " .. math.floor((pmeta:get_int("ticket_vending_machine:elapsed_time") - minetest.get_gametime()) / 60) .. " Minutes."
  end

  minetest.show_formspec(player:get_player_name(), "ticket_vending_machine:machine", "size[5,4]"..
  "label[0.9,0.2;Ticket:]" ..
  "button[0.5,1;2,1;button1;"..BUTTON1_TEXT.."]" ..
  "button[0.5,2;2,1;button2;"..BUTTON2_TEXT.."]"..
  "label[3.5,0.2;Price:]" ..
  "label[3.7,1.2;"..BUTTON1_PRICE.."]" ..
  "label[3.7,2.2;"..BUTTON2_PRICE.."]"..
  "label[0,3.4;"..string_expiring.."]")
end


minetest.register_on_player_receive_fields(function(customer, formname, fields)
	if formname == "ticket_vending_machine:machine" and fields.button1 ~= nil and fields.button1 ~= "" then
    local pmeta = customer:get_meta()
    if pmeta:get_int("ticket_vending_machine:elapsed_time") - minetest.get_gametime() < 0 then
      if jeans_economy_book(customer:get_player_name(), "!SERVER!", BUTTON1_PRICE, customer:get_player_name().." has buyed a ticket for "..BUTTON1_TEXT..".") then
        pmeta:set_int("ticket_vending_machine:elapsed_time", minetest.get_gametime() + BUTTON1_SECONDS)
        ticket_vending_machine_show_spec(customer)
      else
        minetest.chat_send_player(customer:get_player_name(),"You don't have enough money on your account!" )
      end
    end
  end
end)

minetest.register_on_player_receive_fields(function(customer, formname, fields)
	if formname == "ticket_vending_machine:machine" and fields.button2 ~= nil and fields.button2 ~= "" then
    local pmeta = customer:get_meta()
    if pmeta:get_int("ticket_vending_machine:elapsed_time") - minetest.get_gametime() < 0 then
      if jeans_economy_book(customer:get_player_name(), "!SERVER!", BUTTON2_PRICE, customer:get_player_name().." has buyed a ticket for "..BUTTON2_TEXT..".") then
        pmeta:set_int("ticket_vending_machine:elapsed_time", minetest.get_gametime() + BUTTON2_SECONDS)
        ticket_vending_machine_show_spec(customer)
      else
        minetest.chat_send_player(customer:get_player_name(),"You don't have enough money on your account!" )
      end
    end
  end
end)

function ticket_vending_machine_check_ticket(player)
  if not (minetest.player_exists(player:get_player_name()) and minetest.get_player_information(player:get_player_name()) ~= nil) then
    return nil
  end
  local pmeta = player:get_meta()
  if pmeta:get_int("ticket_vending_machine:elapsed_time") - minetest.get_gametime() < 0 then
    return false
  else
    return true
  end
end

minetest.register_chatcommand("check_ticket", {
    privs = {
    },
    func = function(name, player)
      if player == nil then
        minetest.chat_send_player(name, "You should specify a player!")
      else
        if minetest.player_exists(player) and minetest.get_player_information(player) ~= nil then
          local pmeta = minetest.get_player_by_name(player):get_meta()
          if ticket_vending_machine_check_ticket(minetest.get_player_by_name(player)) then
            minetest.chat_send_player(name, player .. " has a valid ticket")
          else
            minetest.chat_send_player(name, player .. " has no valid ticket! The last ticket expired " .. math.floor(math.abs((pmeta:get_int("ticket_vending_machine:elapsed_time") - minetest.get_gametime()) / 60)) .. " Minutes ago."  )
          end
        else
         minetest.chat_send_player(name, "Player not online/doesnt exist")
        end
      end
    end
})
