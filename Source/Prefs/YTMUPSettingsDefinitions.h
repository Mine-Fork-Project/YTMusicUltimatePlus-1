/**
 * YTMUPSettingsDefinitions.h
 *
 * Declares the single entry point that registers every settings page.
 * Call YTMUPRegisterAllSettings() once from %ctor in Settings.x.
 */

#pragma once

#ifdef __cplusplus
extern "C" {
#endif

void YTMUPRegisterAllSettings(void);

#ifdef __cplusplus
}
#endif
