extends Node

const SETTINGS_PATH := "user://settings.cfg"
const SFX_BUS_NAME := "SFX"
const BGM_BUS_NAME := "BGM"
const MUTE_DB := -80.0

var last_score := 0.0
var hidden_mode := false
var sfx_enabled := true
var sfx_volume := 1.0
var bgm_enabled := true
var bgm_volume := 0.6


func _ready() -> void:
	_ensure_bus(SFX_BUS_NAME)
	_ensure_bus(BGM_BUS_NAME)
	_load_settings()
	_apply_sfx_settings()
	_apply_bgm_settings()


func _ensure_bus(bus_name: String) -> void:
	if AudioServer.get_bus_index(bus_name) == -1:
		var idx := AudioServer.bus_count
		AudioServer.add_bus(idx)
		AudioServer.set_bus_name(idx, bus_name)
		AudioServer.set_bus_send(idx, "Master")


func _load_settings() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SETTINGS_PATH) != OK:
		return
	sfx_enabled = cfg.get_value("audio", "sfx_enabled", true)
	sfx_volume = cfg.get_value("audio", "sfx_volume", 1.0)
	bgm_enabled = cfg.get_value("audio", "bgm_enabled", true)
	bgm_volume = cfg.get_value("audio", "bgm_volume", 0.6)


func save_settings() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("audio", "sfx_enabled", sfx_enabled)
	cfg.set_value("audio", "sfx_volume", sfx_volume)
	cfg.set_value("audio", "bgm_enabled", bgm_enabled)
	cfg.set_value("audio", "bgm_volume", bgm_volume)
	cfg.save(SETTINGS_PATH)


func set_sfx_enabled(enabled: bool) -> void:
	sfx_enabled = enabled
	_apply_sfx_settings()
	save_settings()


func set_sfx_volume(volume: float) -> void:
	sfx_volume = clampf(volume, 0.0, 1.0)
	_apply_sfx_settings()
	save_settings()


func set_bgm_enabled(enabled: bool) -> void:
	bgm_enabled = enabled
	_apply_bgm_settings()
	save_settings()


func set_bgm_volume(volume: float) -> void:
	bgm_volume = clampf(volume, 0.0, 1.0)
	_apply_bgm_settings()
	save_settings()


func _apply_sfx_settings() -> void:
	_apply_bus_settings(SFX_BUS_NAME, sfx_enabled, sfx_volume)


func _apply_bgm_settings() -> void:
	_apply_bus_settings(BGM_BUS_NAME, bgm_enabled, bgm_volume)


func _apply_bus_settings(bus_name: String, enabled: bool, volume: float) -> void:
	var idx := AudioServer.get_bus_index(bus_name)
	if idx == -1:
		return
	AudioServer.set_bus_mute(idx, not enabled)
	var db := MUTE_DB if volume <= 0.0 else linear_to_db(volume)
	AudioServer.set_bus_volume_db(idx, db)
