//  Copyright (C) 2018(-2024) Reinhard <octave-user@a1.net>

// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program; If not, see <http://www.gnu.org/licenses/>.

#include "config.h"
#include <octave/oct.h>
#include <stdint.h>

#include <vector>
#include <string>

#if defined(HAVE_PROCESS_H)
#include <process.h>
#else
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/wait.h>
#include <sys/time.h>
#include <sys/resource.h>
#endif

// PKG_ADD: autoload ("spawn", "__mboct_octave_proc__.oct");
// PKG_DEL: autoload ("spawn", "__mboct_octave_proc__.oct", "remove");

DEFUN_DLD(spawn, args, nargout,
          "-*- texinfo -*-\n"
          "@deftypefn  {} @var{pid} = spawn(@var{command}, @var{args})\n"
          "@deftypefnx {} @var{pid} = spawn(@var{command}, @var{args}, @var{output_file})\n"
          "Start the program identified by @var{command} on Unix or Windows systems and return it's @var{pid}\n\n"
          "@var{command} @dots{} Character string name of the program.\n\n"
          "@var{args} @dots{} Arguments passed to the program as a cell array of char strings.\n\n"
          "@example\n"
          "@var{pid} = spawn(\"ls\", @{\"-lhF\",\".\"@});\n"
          "@var{status} = spawn_wait(@var{pid});\n"
          "@end example\n"
          "@end deftypefn\n")
{
     octave_value_list retval;

     if (args.length() < 1 || args.length() > 3 || nargout > 1)
     {
          print_usage();
          return retval;
     }

     if (!args(0).is_string())
     {
          error("command must be a string");
          return retval;
     }

     std::string strCommand = args(0).string_value();

     Cell rgArgs;

     if (args.length() >= 2)
     {
          if (!args(1).OV_ISCELL())
          {
               error("arguments must be an cell array");
               return retval;
          }

          rgArgs = args(1).cell_value();
     }

     for (octave_idx_type i = 0; i < rgArgs.numel(); ++i)
     {
          if (!rgArgs(i).is_string())
          {
               error("argument(%Ld) is not a string", static_cast<long long>(i));
               return retval;
          }
     }

     int fd = -1;

     if (args.length() >= 3)
     {
#if defined(HAVE_VFORK)
          if (!args(2).is_string())
          {
               error("output_file must be a string");
               return retval;
          }

          const std::string strOutputFile = args(2).string_value();

          fd = open(strOutputFile.c_str(), O_CREAT | O_TRUNC | O_WRONLY, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);

          if (fd == -1)
          {
               error("failed to open file \"%s\": %s", strOutputFile.c_str(), strerror(errno));
               return retval;
          }
#else
          warning_with_id("spawn:output_file", "parameter output_file is ignored");
#endif
     }


     bool status = false;

     std::vector<char*> rgArgsVec;

     rgArgsVec.reserve(rgArgs.numel() + 1);

     size_t nCommandLen = 0;

     for (octave_idx_type i = 0; i < rgArgs.numel(); ++i)
     {
          nCommandLen += rgArgs(i).length() + 1;
     }

     strCommand.reserve(strCommand.length() + nCommandLen + 2);

     rgArgsVec.push_back(&strCommand[0]);

     for (octave_idx_type i = 0; i < rgArgs.numel(); ++i)
     {
          strCommand += '\0';
          size_t nSize = strCommand.length();
          strCommand += rgArgs(i).string_value();
          rgArgsVec.push_back(&strCommand[nSize]);
     }

     rgArgsVec.push_back(0);

     for (int i = 0; i < 2; ++i) {
          strCommand += '\0';
     }

#if defined(HAVE_SPAWNVP)
     pid_t pid = spawnvp(_P_NOWAIT, &strCommand[0], &rgArgsVec.front());
     status = pid != 0;
#elif defined(HAVE__SPAWNVP)
     pid_t pid = _spawnvp(_P_NOWAIT, &strCommand[0], &rgArgsVec.front());
     status = pid != 0;
#else
     pid_t pid = fork();

     if (pid > 0)
     {
          status = true;
     }
     else if (pid == 0)
     {
          if (fd != -1)
          {
               dup2(fd, STDOUT_FILENO);
               dup2(fd, STDERR_FILENO);
          }

          execvp(&strCommand[0], &rgArgsVec.front());
          _exit(1);
     }
     else
     {
          status = false;
     }
#endif
     if (fd != -1)
     {
          close(fd);
     }

     if (!status)
     {
          error("failed to start process \"%s\": %s", strCommand.c_str(), strerror(errno));
          return retval;
     }

     retval.append(octave_uint64(pid));

     return retval;
}

// PKG_ADD: autoload ("spawn_wait", "__mboct_octave_proc__.oct");
// PKG_DEL: autoload ("spawn_wait", "__mboct_octave_proc__.oct", "remove");

DEFUN_DLD(spawn_wait, args, nargout,
          "-*- texinfo -*-\n"
          "@deftypefn  {} @var{status} = spawn_wait(@var{pid})\n"
          "@deftypefnx  {} [@var{status}, @var{pid}] = spawn_wait(@var{pid},@var{options})\n"
          "Wait until the program identified by @var{pid} exits and return it's exit status\n\n"
          "@example\n"
          "@var{pid} = spawn(\"ls\", @{\"-lhF\",\".\"@});\n"
          "@var{status} = spawn_wait(@var{pid});\n"
          "@end example\n"
          "@end deftypefn\n")
{
     octave_value_list retval;

     if (args.length() < 1 || args.length() > 2 || nargout > 2)
     {
          print_usage();
          return retval;
     }

     if (!(args(0).is_scalar_type() && args(0).OV_ISINTEGER()))
     {
          error("pid must be an integer");
          return retval;
     }

     const pid_t pid = args(0).uint64_value();

     if (args.length() > 1 && !args(1).is_scalar_type())
     {
          error("options must be an integer");
          return retval;
     }

     const int options = args.length() > 1 ? args(1).int_value() : 0;

     int status = 0;

#if defined(HAVE_CWAIT)
     pid_t res = cwait(&status, pid, options);
#elif defined(HAVE__CWAIT)
     pid_t res = _cwait(&status, pid, options);
#else
     pid_t res = ::waitpid(pid, &status, options);
#endif

     if (res != pid && nargout < 2)
     {
          error("failed to wait for process %Ld: %s", static_cast<long long>(pid), strerror(errno));
     }

     retval.append(octave_int32(status));

     if (nargout >= 2) {
          retval.append(octave_uint64(res));
     }

     return retval;
}

// PKG_ADD: autoload ("setpriority", "__mboct_octave_proc__.oct");
// PKG_DEL: autoload ("setpriority", "__mboct_octave_proc__.oct", "remove");

DEFUN_DLD(setpriority, args, nargout,
          "-*- texinfo -*-\n"
          "@deftypefn  {} @var{status} = setpriority(@var{which}, @var{who}, @var{prio})\n"
          "@end deftypefn\n")
{
     octave_value_list retval;

#ifdef HAVE_SETPRIORITY
     if (args.length() != 3)
     {
          print_usage();
          return retval;
     }

     if (!(args(0).is_scalar_type() && args(0).OV_ISINTEGER()))
     {
          error("which must be an integer");
          return retval;
     }

     const int which = args(0).int_value();

     if (!args(1).is_scalar_type())
     {
          error("who must be an integer");
          return retval;
     }

     const int who = args(1).int_value();

     if (!args(2).is_scalar_type())
     {
          error("prio must be an integer");
          return retval;
     }

     const int prio = args(2).int_value();

     int status = setpriority(which, who, prio);

     retval.append(octave_int32(status));
#else
     error("setpriority is not available on this system");
#endif

     return retval;
}

// PKG_ADD: autoload ("getpriority", "__mboct_octave_proc__.oct");
// PKG_DEL: autoload ("getpriority", "__mboct_octave_proc__.oct", "remove");

DEFUN_DLD(getpriority, args, nargout,
          "-*- texinfo -*-\n"
          "@deftypefn  {} @var{status} = getpriority(@var{which}, @var{who})\n"
          "@end deftypefn\n")
{
     octave_value_list retval;

#ifdef HAVE_SETPRIORITY
     if (args.length() != 2)
     {
          print_usage();
          return retval;
     }

     if (!(args(0).is_scalar_type() && args(0).OV_ISINTEGER()))
     {
          error("which must be an integer");
          return retval;
     }

     const int which = args(0).int_value();

     if (!args(1).is_scalar_type())
     {
          error("who must be an integer");
          return retval;
     }

     const int who = args(1).int_value();

     const int prio = getpriority(which, who);

     retval.append(octave_int32(prio));
#else
     error("getpriority is not available on this system");
#endif

     return retval;
}

// PKG_ADD: autoload ("PRIO_PROCESS", "__mboct_octave_proc__.oct");
// PKG_DEL: autoload ("PRIO_PROCESS", "__mboct_octave_proc__.oct", "remove");

DEFUN_DLD(PRIO_PROCESS, args, nargout,
          "-*- texinfo -*-\n"
          "@deftypefn  {} @var{flag} = PRIO_PROCESS()\n"
          "@end deftypefn\n")
{
#ifdef HAVE_SETPRIORITY
     return octave_value(octave_int32(PRIO_PROCESS));
#else
     error("PRIO_PROCESS is not available on this system");
     return octave_value();
#endif
}

// PKG_ADD: autoload ("PRIO_PGRP", "__mboct_octave_proc__.oct");
// PKG_DEL: autoload ("PRIO_PGRP", "__mboct_octave_proc__.oct", "remove");

DEFUN_DLD(PRIO_PGRP, args, nargout,
          "-*- texinfo -*-\n"
          "@deftypefn  {} @var{flag} = PRIO_PGRP()\n"
          "@end deftypefn\n")
{
#ifdef HAVE_SETPRIORITY
     return octave_value(octave_int32(PRIO_PGRP));
#else
     error("PRIO_PGRP is not available on this system");
     return octave_value();
#endif
}

// PKG_ADD: autoload ("PRIO_USER", "__mboct_octave_proc__.oct");
// PKG_DEL: autoload ("PRIO_USER", "__mboct_octave_proc__.oct", "remove");

DEFUN_DLD(PRIO_USER, args, nargout,
          "-*- texinfo -*-\n"
          "@deftypefn  {} @var{flag} = PRIO_USER()\n"
          "@end deftypefn\n")
{
#ifdef HAVE_SETPRIORITY
     return octave_value(octave_int32(PRIO_USER));
#else
     error("PRIO_USER is not available on this system");
     return octave_value();
#endif
}

/*
%!error spawn();

%!test spawn_wait(spawn("ls"));
%!error spawn("ls",{"-l"},"");

%!error [a, b] = spawn("ls",{"-l"});

%!test
%! pid = spawn("ls", {"-l"});
%! rc = spawn_wait(pid);
%! assert(rc, int32(0));

%!test
%! tic
%! for i=1:100
%! pid = spawn("printf", {"\"%s %d\"\n", "test", sprintf("%d", i)});
%! assert(spawn_wait(pid) == uint32(0));
%! endfor
%! toc

%!demo
%! pid = spawn("octave-config", {"-p", "VERSION"});
%! status = spawn_wait(pid);
%! assert(status, int32(0));
*/
