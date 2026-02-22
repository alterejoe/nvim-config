local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node

return {

  s("noticeprimary", {
    t("@components.PrimaryNotice(&structs.Notice{})"),
  }),

  s("noticesecondary", {
    t("@components.SecondaryNotice(&structs.Notice{})"),
  }),

  s("noticetertiary", {
    t("@components.TertiaryNotice(&structs.Notice{})"),
  }),

  s("noticeaccent", {
    t("@components.AccentNotice(&structs.Notice{})"),
  }),

  s("noticeunique", {
    t("@components.UniqueNotice(&structs.Notice{})"),
  }),

  s("noticeattention", {
    t("@components.AttentionNotice(&structs.Notice{})"),
  }),

}
