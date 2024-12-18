local function set(tbl, var, val)
	tbl[var] = val ~= nil and val or tbl[var]
end

local Stage = Group:extend("Stage")

function Stage:new(name)
	Stage.super.new(self)

	if name == nil then name = "stage" end
	self.name = name

	self.camZoom, self.camSpeed, self.camZoomSpeed = 1.1, 1, 1

	self.boyfriendPos = {x = 770, y = 100}
	self.gfPos = {x = 400, y = 130}
	self.dadPos = {x = 100, y = 100}

	self.boyfriendCam = {x = 0, y = 0}
	self.gfCam = {x = 0, y = 0}
	self.dadCam = {x = 0, y = 0}

	self.foreground = Group()

	if name ~= "" then
		local path = "stages/" .. name
		self.path = path .. "/"

		local json = paths.getJSON("data/" .. path)
		if paths.getLua("data/" .. path) == nil and json == nil then
			print("[STAGE] Stage \"" .. name .. "\" doesn't exists")
			path = "stages/default"
			self.path = path .. "/"
		end

		self.script = Script("data/" .. path, false)
		self.script:set("SCRIPT_PATH", path .. "/")
		self.script:set("self", self)

		if json then
			for _, spr in ipairs(json.sprites) do
				local sprite = self:makeSpriteFromData(spr)
				self:add(sprite, spr.is_foreground)
			end
			if json.bf then
				if json.bf.position then
					set(self.boyfriendPos, "x", json.bf.position[1])
					set(self.boyfriendPos, "y", json.bf.position[2])
				end
				if json.bf.camera_offsets then
					set(self.boyfriendCam, "x", json.bf.camera_offsets[1])
					set(self.boyfriendCam, "y", json.bf.camera_offsets[2])
				end
			end
			if json.gf then
				if json.gf.position then
					set(self.gfPos, "x", json.gf.position[1])
					set(self.gfPos, "y", json.gf.position[2])
				end
				if json.gf.camera_offsets then
					set(self.gfCam, "x", json.gf.camera_offsets[1])
					set(self.gfCam, "y", json.gf.camera_offsets[2])
				end
			end
			if json.dad then
				if json.dad.position then
					set(self.dadPos, "x", json.dad.position[1])
					set(self.dadPos, "y", json.dad.position[2])
				end
				if json.dad.camera_offsets then
					set(self.dadCam, "x", json.dad.camera_offsets[1])
					set(self.dadCam, "y", json.dad.camera_offsets[2])
				end
			end

			set(self, "camZoom", json.camera_zoom)
			set(self, "camSpeed", json.camera_speed)
			set(self, "camZoomSpeed", json.camera_zoom_speed)
		end

		self.script:call("create")
	end
end

function Stage:makeSpriteFromData(data)
	local spr = Sprite()
	if data.animations then
		spr:setFrames(paths.getAtlas(self.path .. data.asset_path))
	else
		spr:loadTexture(paths.getImage(self.path .. data.asset_path))
	end
	if data.position then
		spr:setPosition(data.position[1] or 0, data.position[2] or 0)
	end
	if data.scale then
		spr:setGraphicSize(spr.width * (data.scale[1] or 1),
			spr.height * (data.scale[2] or 1))
	end
	if data.scroll then
		spr:setScrollFactor(data.scroll[1] or 1, data.scroll[2] or 2)
	end
	if data.props then
		for prop, val in ipairs(data.props) do
			spr[prop] = val
		end
	end

	self.script:set(data.name, spr)

	return spr
end

function Stage:add(obj, foreground)
	if foreground then
		self.foreground:add(obj)
	else
		Stage.super.add(self, obj)
	end
end

return Stage
