local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node

return {

  s("strcommon", {
    t({
      [[structs.Common{]],
      [[	ID: "",]],
      [[	Name: "",]],
      [[	Class: "",]],
      [[	Value: "",]],
      [[	Disabled: false,]],
      [[}]],
    }),
  }),

  s("strhx", {
    t({
      [[structs.Hx{]],
      [[	Method: "",]],
      [[	Params: "",]],
      [[	URL: "",]],
      [[	Target: "",]],
      [[	Include: "",]],
      [[	Trigger: "",]],
      [[	Swap: "",]],
      [[	Indicator: "",]],
      [[	Vals: "",]],
      [[	Confirm: "",]],
      [[	PushURL: "",]],
      [[	Boost: false,]],
      [[	OnAfterRequest: "",]],
      [[	OnBeforeRequest: "",]],
      [[	OnAfterSettle: "",]],
      [[	Select: "",]],
      [[	SelectOOB: "",]],
      [[	SwapOOB: "",]],
      [[	Preserve: false,]],
      [[	Sync: "",]],
      [[	Disabled: false,]],
      [[	Encoding: "",]],
      [[}]],
    }),
  }),

  s("strformbehaviors", {
    t({
      [[structs.FormBehaviors{]],
      [[	Constraint: "",]],
      [[	DirtyWatch: false,]],
      [[	DirtyGroup: "",]],
      [[	EnableOnValid: false,]],
      [[	EnableTarget: "",]],
      [[	ConstraintForm: false,]],
      [[}]],
    }),
  }),

}
