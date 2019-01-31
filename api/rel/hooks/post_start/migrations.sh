#!/bin/sh
echo "Mirror started! Running Database migrations"
$RELEASE_ROOT_DIR/bin/mirror command Elixir.Mirror.ReleaseTasks migrate