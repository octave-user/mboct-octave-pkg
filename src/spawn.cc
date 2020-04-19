//  Copyright (C) 2018(-2020) Reinhard <octave-user@a1.net>

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
#include <sys/wait.h>
#endif

// PKG_ADD: autoload ("spawn", "__mboct_octave_proc__.oct");
// PKG_DEL: autoload ("spawn", "__mboct_octave_proc__.oct", "remove");

DEFUN_DLD(spawn, args, nargout,
          "-*- texinfo -*-\n"
          "@deftypefn  {} @var{pid} = spawn(@var{command}, @var{args})\n" 
          "Start the program @var{command} on Unix or Windows systems and return it's @var{pid}\n\n"
          "@var{args} @dots{} Arguments passed to the program as a cell array of char strings.\n\n"          
          "@example\n"
          "@var{pid} = spawn(\"ls\", @{\"-lhF\",\".\"@});\n"
          "@var{status} = spawn_wait(@var{pid});\n"
          "@end example\n"
          "@end deftypefn\n")
{
    octave_value_list retval;

    if (args.length() < 1 || args.length() > 2 || nargout > 1)
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
    pid_t pid = vfork();

    if (pid > 0)
    {
        status = true;
    }
    else if (pid == 0)
    {
        execvp(&strCommand[0], &rgArgsVec.front());  
        _exit(1);
    }
    else
    {
        status = false;
    }
#endif
        
    if (!status)
    {
      error("failed to start process \"%s\"", strCommand.c_str());
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
          "Wait until the program identified by @var{pid} exits and return it's exit status\n\n"         
          "@example\n"
          "@var{pid} = spawn(\"ls\", @{\"-lhF\",\".\"@});\n"
          "@var{status} = spawn_wait(@var{pid});\n"
          "@end example\n"
          "@end deftypefn\n")
{
    octave_value_list retval;

    if (args.length() != 1)
    {
      print_usage();
      return retval;
    }

    if (!(args(0).is_scalar_type() && args(0).OV_ISINTEGER()))
    {
        error("pid must be an integer");
        return retval;
    }
    
    pid_t pid = args(0).uint64_value();
    int status = 0;

#if defined(HAVE_CWAIT)
    pid_t res = cwait(&status, pid, 0);
#elif defined(HAVE__CWAIT)
    pid_t res = _cwait(&status, pid, 0);
#else
    pid_t res = ::waitpid(pid, &status, 0);
   
    if (res == pid)
    {
        if (WIFEXITED(status))
        {
            status = WEXITSTATUS(status);
        }
        else
        {
            if (WIFSIGNALED(status))
            {
                error("process %d killed by signal %d", pid, WTERMSIG(status));
            }
            else if(WIFSTOPPED(status))
            {
                error("process %d stopped", pid);
            }
            else if (WIFCONTINUED(status))
            {
                error("process %d continued", pid);
            }
            else
            {
                error("an unknown error occured in process %d", pid);
            }
            
            status = -1;
        }
    }
#endif

    if (res != pid)
    {
        error("failed to wait for process %Ld", static_cast<long long>(pid));
        status = -1;
    }
    
    retval.append(status);

    return retval;
}

/*
%!error spawn();

%!test spawn_wait(spawn("ls"));

%!error spawn("ls",{"-l"},"");

%!error [a, b] = spawn("ls",{"-l"});

%!test
%! pid = spawn("ls", {"-l"});
%! rc = spawn_wait(pid);
%! assert(rc, 0);

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
%! assert(status, 0);
*/

