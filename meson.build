project(
  'libmali',
  version : '2.0.0',
  meson_version : '>=0.47.0',
)

pkgconfig = import('pkgconfig')

soname = 'libmali.so.1'

if get_option('arch') != 'auto'
  arch = get_option('arch')
else
  arch = host_machine.cpu_family()
endif

gpu = get_option('gpu')
version = get_option('version')
subversion = get_option('subversion')
platform = get_option('platform')

# Grab libraries with specified configs
c = run_command('grabber.sh', arch, gpu, version, subversion, platform)
libs = c.stdout().strip().split('\n')

# Use the first one as default library
mali_lib = libs[0]
if mali_lib == ''
  error('failed to find matched library.')
endif

message('building for @0@'.format(libs))

mali_links = [
  [soname, 'libmali.so'],
  ['libmali.so', 'libMali.so'],
  ['libmali.so', mali_lib.split('/')[-1]],
]
gbm_links = [
  [soname, 'libgbm.so.1'],
  ['libgbm.so.1', 'libgbm.so'],
]
egl_links = [
  [soname, 'libEGL.so.1'],
  ['libEGL.so.1', 'libEGL.so'],
]
glesv1_links = [
  [soname, 'libGLESv1_CM.so.1'],
  ['libGLESv1_CM.so.1', 'libGLESv1_CM.so'],
]
glesv2_links = [
  [soname, 'libGLESv2.so.2'],
  ['libGLESv2.so.2', 'libGLESv2.so'],
]
wayland_links = [
  [soname, 'libwayland-egl.so.1'],
  ['libwayland-egl.so.1', 'libwayland-egl.so'],
]
cl_links = [
  [soname, 'libOpenCL.so.1'],
  ['libOpenCL.so.1', 'libOpenCL.so'],
  ['libOpenCL.so', 'libMaliOpenCL.so'],
]

# Subdir : headers
mali_headers = {
  'KHR' : ['include/KHR/mali_khrplatform.h'],
}
egl_headers = {
  'EGL' : [
    'include/EGL/eglplatform.h',
    'include/EGL/eglext.h',
    'include/EGL/egl.h',
  ],
}
glesv1_headers = {
  'GLES' : [
    'include/GLES/gl.h',
    'include/GLES/glplatform.h',
    'include/GLES/glext.h',
    'include/GLES/egl.h',
  ],
}
glesv2_headers = {
  'GLES2' : [
    'include/GLES2/gl2ext.h',
    'include/GLES2/gl2.h',
    'include/GLES2/gl2platform.h',
  ],
  'GLES3' : [
    'include/GLES3/gl3.h',
    'include/GLES3/gl32.h',
    'include/GLES3/gl3platform.h',
    'include/GLES3/gl31.h',
  ],
}
cl_headers = {
  'CL': [
    'include/CL/cl_gl.h',
    'include/CL/cl.h',
    'include/CL/cl_dx9_media_sharing_intel.h',
    'include/CL/cl_ext_intel.h',
    'include/CL/cl_d3d10.h',
    'include/CL/opencl.h',
    'include/CL/cl_d3d11.h',
    'include/CL/cl_platform.h',
    'include/CL/cl_ext.h',
    'include/CL/cl_egl.h',
    'include/CL/cl_dx9_media_sharing.h',
    'include/CL/cl_va_api_media_sharing_intel.h',
    'include/CL/cl_gl_ext.h',
  ],
}

# Package name : required symbol, symlinks, headers, package version
map = {
  'mali' : ['', mali_links, mali_headers, '2.0.0'],
  'gbm' : ['gbm_create_device', gbm_links, {'' : 'include/gbm.h'}, '10.4.0'],
  'egl' : ['eglCreateContext', egl_links, egl_headers, '7.10'],
  'glesv1_cm' : ['eglCreateContext', glesv1_links, glesv1_headers, '7.10'],
  'glesv2' : ['eglCreateContext', glesv2_links, glesv2_headers, '7.10'],
  'wayland-egl' : ['wl_egl_window_create', wayland_links, {}, '18.1.0'],
  'OpenCL' : ['clCreateContext', cl_links, cl_headers, '1.2'],
}

mali_cflags = []
if platform != 'x11'
  mali_cflags += '-DMESA_EGL_NO_X11_HEADERS'
endif

# Install libraries and rename the default one to soname
foreach lib : libs
  if lib == mali_lib
    install_data(lib, install_dir : get_option('libdir'), rename : soname)
  else
    install_data(lib, install_dir : get_option('libdir'))
  endif
endforeach

foreach name, values : map
  symbol = values[0]
  links = values[1]
  headers = values[2]
  pkg_version = values[3]

  # TODO: Use readelf -s ?
  if run_command('grep', '-q', symbol, mali_lib).returncode() != 0
    continue
  endif

  foreach link : links
    # HACK: Create symlink with tracking
    install_data(mali_lib, install_dir : get_option('libdir'), rename : link[1])
    meson.add_install_script('link.sh', get_option('libdir'), link)
  endforeach

  foreach dir, files : headers
    install_headers(files, subdir : dir)
  endforeach

  pkgconfig.generate(
    libraries : '-L${libdir} -lmali',
    extra_cflags : mali_cflags,
    version : pkg_version,
    name : name,
    description : 'Mali GPU User-Space Binary Drivers'
  )

  if name == 'OpenCL'
    install_data('include/mali.icd', install_dir : get_option('sysconfdir') / 'OpenCL' / 'vendors')
  endif
endforeach

if get_option('with-overlay')
  if gpu == 'utgard-400' and subversion == 'r3p0'
    install_data('overlay/S10libmali_px3se', install_dir : get_option('sysconfdir') / 'init.d')
    install_data('overlay/px3seBase', install_dir : get_option('bindir'))
  endif

  if gpu == 'midgard-t76x' and subversion == 'all'
    install_data('overlay/S10libmali_rk3288', install_dir : get_option('sysconfdir') / 'init.d')
  endif
endif
