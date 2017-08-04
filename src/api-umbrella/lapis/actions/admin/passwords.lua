local Admin = require "api-umbrella.lapis.models.admin"
local admin_reset_password_mailer = require "api-umbrella.lapis.mailers.admin_reset_password"
local flash = require "api-umbrella.utils.lapis_flash"
local is_empty = require("pl.types").is_empty
local t = require("resty.gettext").gettext

local _M = {}

function _M.new()
  return { render = "admin.passwords.new" }
end

function _M.create(self)
  local admin
  if self.params and self.params["admin"] then
    local email = self.params["admin"]["email"]
    if not is_empty(email) then
      admin = Admin:find({ email = email })
    end
  end

  if admin then
    local token = admin:set_reset_password_token()
    admin_reset_password_mailer(admin, token)
  end

  flash.session(self, "info", t("If your email address exists in our database, you will receive a password recovery link at your email address in a few minutes."))
  return self:write({ redirect_to = "/admin/login" })
end

function _M.edit()
end

function _M.update()
end

function _M.admin_params(self)
  local params = {}
  if self.params and self.params["admin"] then
    local input = self.params["admin"]
    params = {
      email = input["email"],
    }
  end

  return params
end

return function(app)
  app:get("/admins/password/new(.:format)", _M.new)
  app:post("/admins/password(.:format)", _M.create)
  app:get("/admins/password/edit(.:format)", _M.edit)
  app:put("/admins/password(.:format)", _M.update)
end