KillLogBox = KillLogBox or class()
function KillLogBox:init(hud)
    self._full_hud = hud
    self._killog_panel = self._full_hud:panel({
        name = "killog_panel", 
        alpha = 0,
        layer = 100,
    })
    self._kill_text = self._killog_panel:text({
        name = "kill_text",
        vertical = "center",
        align = "center",
        text = "0",
        font_size = KillLog.Opt.size,
        layer = 2,
        color = KillLog.colors[KillLog.Opt.textcolor].color,
        font = "fonts/font_large_mf"
    })   
    self._killog_panel:rect({
        name = "kill_bg",
        halign = "grow",
        valign = "grow",
        layer = 1,
        color = KillLog.colors[KillLog.Opt.bgcolor].color 
    })     
    self:MakeFine()
    self.kills = 0
end

function KillLogBox:Update()
    if not self._started and KillLog.Opt.reset then
        self.kills = 0
    end
    self._kill_text:set_color(KillLog.colors[KillLog.Opt.textcolor].color)
    self._killog_panel:child("kill_bg"):set_color(KillLog.colors[KillLog.Opt.bgcolor].color)
    self._kill_text:set_font_size(KillLog.Opt.size)
    self:MakeFine()
    if not self._started then
        self._killog_panel:set_x(self._full_hud:center_x() - 120)
    end
end

function KillLogBox:MakeFine()
    local w,h = WalletGuiObject.make_fine_text(self._kill_text)
    self._killog_panel:set_size(w + 8, h + 8)
    
    self._kill_text:set_center(self._killog_panel:w() / 2, self._killog_panel:h() / 2)
    self._killog_panel:set_center(self._full_hud:center_x(), self._full_hud:center_y() - 250)    
end

function KillLogBox:SetKills()
    if self._headshot then
        self._headshot = false
        self._kill_text:set_text(" "..tostring(self.kills).." Kills ")
    else
        self._kill_text:set_text(tostring(self.kills).." Kills")
    end

    self:MakeFine()
    
    self._killog_panel:stop()
    self._killog_panel:animate(callback(self, self, "show_KillLog"))
end

function KillLogBox:animate_combo(text)
    local t = 0
    while t < 1 do
        t = t + coroutine.yield()
        local n = 1 - math.sin(t * 360)
        text:set_font_size(math.lerp(KillLog.Opt.size + 6, KillLog.Opt.size, n))
        self:MakeFine()
    end
    text:set_font_size(KillLog.Opt.size)
    self:MakeFine()
end

--Horrible code but eh too lazy, "if it ain't bork"
function KillLogBox:show_KillLog(rect)
    local anim_t = KillLog.Opt.fadetime
    if KillLog.Opt.fadetime > 4 then
        anim_t = 3
    end
    local t = KillLog.Opt.fadetime - anim_t 
    if self._started then
        self._kill_text:animate(callback(self, self, "animate_combo"))
    end
    self._started = true
    while anim_t > 0 do
        anim_t = anim_t - coroutine.yield()
        local n = 1 - math.sin((anim_t / 2) * 400)       
        if self._killog_panel:alpha() < 0.99 then
            self._killog_panel:set_alpha(math.lerp(1, 0, n))
            self._killog_panel:set_center_x(math.lerp(self._full_hud:center_x(), self._full_hud:center_x() - 120, n))
        end
    end
    if KillLog.Opt.fadetime > 4 then
        while t > 0 do
        t = t - coroutine.yield()
        end
    end
    while t < 0.5 do
        t = t + coroutine.yield()
        local n = 1 - math.sin((t / 2) * 350)       
        self._killog_panel:set_alpha(math.lerp(0, 1, n))
        self._killog_panel:set_center_x(math.lerp(self._full_hud:center_x() - 120, self._full_hud:center_x(), n))
    end
    self._started = false
    if KillLog.Opt.reset then
        self.kills = 0
    end
    self._killog_panel:set_alpha(0)
    self._killog_panel:set_x(self._full_hud:center_x() - 120)
end