# Traccar AirTag synchronization

## Overview

A native MacOS service to periodically synchronize AirTag location with Traccar server.

The data is uploaded for all linked tags while the computer is awake.

## Installation

- Download and install package from releases
- In `Settings` > `Privacy & Security` > `Full Disk Access` enable access for `AirtagSync`

If something is not working, check logs using the following command:

- `log show --predicate 'subsystem == "org.traccar.sync"' --info`

## Configuration

Default configuration:

- Server URL is set to the main demo server
- Upload is set to every 10 minutes (600 seconds)

You can change those parameters in the `launchd` configuration:

- `/Library/LaunchAgents/org.traccar.sync.plist`

To apply new configuration, make sure to reload the service:

- `launchctl unload /Library/LaunchAgents/org.traccar.sync.plist`
- `launchctl load /Library/LaunchAgents/org.traccar.sync.plist`
