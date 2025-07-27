#!/bin/bash
# Start Nomad and Consul in development mode

echo "🚀 Starting development services..."

# Check if already running
if pgrep -x "nomad" > /dev/null; then
    echo "✅ Nomad is already running"
else
    echo "Starting Nomad in dev mode..."
    sudo nomad agent -dev > /tmp/nomad.log 2>&1 &
    sleep 5
fi

if pgrep -x "consul" > /dev/null; then
    echo "✅ Consul is already running"
else
    echo "Starting Consul in dev mode..."
    consul agent -dev > /tmp/consul.log 2>&1 &
    sleep 5
fi

echo ""
echo "✅ Services started!"
echo ""
echo "To view logs:"
echo "  Nomad:  tail -f /tmp/nomad.log"
echo "  Consul: tail -f /tmp/consul.log"
echo ""
echo "To stop services:"
echo "  killall nomad consul"