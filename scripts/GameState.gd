extends Node

const SETTINGS_PATH := "user://settings.cfg"
const SFX_BUS_NAME := "SFX"
const MUTE_DB := -80.0

var last_score := 0.0
var hidden_mode := false
var sfx_enabled := true
var sfx_volume := 1.0


func _ready() -> void:
	_ensure_sfx_bus()
	_load_settings()
	_apply_sfx_settings()


func _ensure_sfx_bus() -> void:
	if AudioServer.get_bus_index(SFX_BUS_NAME) == -1:
		var idx := AudioServer.bus_count
		AudioServer.add_bus(idx)
		AudioServer.set_bus_name(idx, SFX_BUS_NAME)
		AudioServer.set_bus_send(idx, "Master")


func _load_settings() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SETTINGS_PATH) != OK:
		return
	sfx_enabled = cfg.get_value("audio", "sfx_enabled", true)
	sfx_volume = cfg.get_value("audio", "sfx_volume", 1.0)


func save_settings() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("audio", "sfx_enabled", sfx_enabled)
	cfg.set_value("audio", "sfx_volume", sfx_volume)
	cfg.save(SETTINGS_PATH)


func set_sfx_enabled(enabled: bool) -> void:
	sfx_enabled = enabled
	_apply_sfx_settings()
	save_settings()


func set_sfx_volume(volume: float) -> void:
	sfx_volume = clampf(volume, 0.0, 1.0)
	_apply_sfx_settings()
	save_settings()


func _apply_sfx_settings() -> void:
	var idx := AudioServer.get_bus_index(SFX_BUS_NAME)
	if idx == -1:
		return
	AudioServer.set_bus_mute(idx, not sfx_enabled)
	var db := MUTE_DB if sfx_volume <= 0.0 else linear_to_db(sfx_volume)
	AudioServer.set_bus_volume_db(idx, db)
