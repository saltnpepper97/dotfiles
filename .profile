# Use AMD ACO shader compiler for RADV
export RADV_PERFTEST=aco

# Enable async shader compilation for smoother frame times
export RADV_DEBUG=lazy_alloc

# Let gamemode and the scheduler optimize threads
export GAMEMODERUN=1

# Prevent unnecessary CPU frequency scaling delays (optional)
export SDL_VIDEO_GL_DRIVER=mesa
export SDL_VIDEO_FULLSCREEN_DISPLAY=0  # force monitor 0

# Use high precision for OpenGL/Vulkan
export MESA_GLSL_CACHE_DISABLE=0
