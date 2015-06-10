{application, life,
 [{description, "Conway's Game of Life Server"},
  {vsn, "0.1.0"},
  {modules, [life_app,
             life_sup,
             life]},
  {registered, [life_sup]},
  {applications, [kernel, stdlib]},
  {mod, {life_app, []}}
 ]}.
