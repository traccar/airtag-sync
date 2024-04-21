# Traccar AirTag synchronization

## Overview

A native MacOS service to periodically synchronize AirTag location with Traccar server.

The data is uploaded for all linked tags while the computer is awake.

## Installation

- Download and install package from releases
- In Settings > Privacy & Security > Full Disk Access enable access for `AirtagSync`

## Configuration

Default configuration:

- Server URL is set to the main demo server
- Upload is set to every 10 minutes (600 second)

You can change thos parameters in the `launchd` configuration:

- `/Library/LaunchAgents/org.traccar.sync.plist`
