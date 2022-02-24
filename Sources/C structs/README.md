WARNING: Not finished (and it will never be, we don't want it!).

If we declare our objects in C we will get the C-layout. Then we can import them into Swift. This is nice because C layout is predictable and well described (see: cppreference.com: type).

Unfortunately this has its own problems, most notably that some of the properties on our Swift types are not trivially representable in C.

As far as I know this is the “official” (recommended by Swift team) way of dealing with this situation.
