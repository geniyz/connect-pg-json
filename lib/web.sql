--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: web; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA web;


ALTER SCHEMA web OWNER TO postgres;

SET search_path = web, pg_catalog;

--
-- Name: clear_sessions(); Type: FUNCTION; Schema: web; Owner: postgres
--

CREATE FUNCTION clear_sessions() RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO web, pg_temp
    AS $$
			begin 
				delete from web.session;
			end;
		$$;


ALTER FUNCTION web.clear_sessions() OWNER TO postgres;

--
-- Name: count_sessions(); Type: FUNCTION; Schema: web; Owner: postgres
--

CREATE FUNCTION count_sessions() RETURNS integer
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO web, pg_temp
    AS $$
			declare
				thecount int := 0;
			begin
				select count(*) into thecount
					from web.valid_sessions();
				return thecount;
			end;
		$$;


ALTER FUNCTION web.count_sessions() OWNER TO postgres;

--
-- Name: destroy_session(text); Type: FUNCTION; Schema: web; Owner: postgres
--

CREATE FUNCTION destroy_session(sessid text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO web, pg_temp
    AS $$
			begin
				delete from web.session where sess_id = sessid;
			end;
		$$;


ALTER FUNCTION web.destroy_session(sessid text) OWNER TO postgres;

--
-- Name: get_session_data(text); Type: FUNCTION; Schema: web; Owner: postgres
--

CREATE FUNCTION get_session_data(sessid text) RETURNS SETOF json
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO web, pg_temp
    AS $$
			begin
				return query select sess_data 
					from web.valid_sessions()
					where sess_id = sessid;
			end;
		$$;


ALTER FUNCTION web.get_session_data(sessid text) OWNER TO postgres;

--
-- Name: remove_expired(); Type: FUNCTION; Schema: web; Owner: postgres
--

CREATE FUNCTION remove_expired() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO web, pg_temp
    AS $$
			begin
				delete from web.session where expiration < now();
				return null;
			end;
		$$;


ALTER FUNCTION web.remove_expired() OWNER TO postgres;

--
-- Name: set_session_data(text, json, timestamp with time zone); Type: FUNCTION; Schema: web; Owner: postgres
--

CREATE FUNCTION set_session_data(sessid text, sessdata json, expire timestamp with time zone) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO web, pg_temp
    AS $$
			begin
				loop
					update web.session 
						set sess_data = sessdata, 
							expiration = expire 
						where sess_id = sessid;
					if found then
						return;
					end if;
					begin
						insert into web.session (sess_id, sess_data, expiration) 
							values (sessid, sessdata, expire);
						return;
					exception
						when unique_violation then
							-- do nothing.
					end;
				end loop;
			end;
		$$;


ALTER FUNCTION web.set_session_data(sessid text, sessdata json, expire timestamp with time zone) OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: session; Type: TABLE; Schema: web; Owner: postgres; Tablespace: 
--

CREATE TABLE session (
    sess_id text NOT NULL,
    sess_data json,
    expiration timestamp with time zone DEFAULT (now() + '1 day'::interval)
);


ALTER TABLE web.session OWNER TO postgres;

--
-- Name: valid_sessions(); Type: FUNCTION; Schema: web; Owner: postgres
--

CREATE FUNCTION valid_sessions() RETURNS SETOF session
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO web, pg_temp
    AS $$
			begin
				return query select * from web.session
					where expiration > now() 
						or expiration is null;
			end;
		$$;


ALTER FUNCTION web.valid_sessions() OWNER TO postgres;

--
-- Name: session_pkey; Type: CONSTRAINT; Schema: web; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY session
    ADD CONSTRAINT session_pkey PRIMARY KEY (sess_id);


--
-- Name: expire_idx; Type: INDEX; Schema: web; Owner: postgres; Tablespace: 
--

CREATE INDEX expire_idx ON session USING btree (expiration);


--
-- Name: delete_expired_trig; Type: TRIGGER; Schema: web; Owner: postgres
--

CREATE TRIGGER delete_expired_trig AFTER INSERT OR UPDATE ON session FOR EACH STATEMENT EXECUTE PROCEDURE remove_expired();


--
-- Name: web; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA web FROM PUBLIC;
REVOKE ALL ON SCHEMA web FROM postgres;
GRANT ALL ON SCHEMA web TO postgres;
GRANT USAGE ON SCHEMA web TO geniyz;


--
-- Name: clear_sessions(); Type: ACL; Schema: web; Owner: postgres
--

REVOKE ALL ON FUNCTION clear_sessions() FROM PUBLIC;
REVOKE ALL ON FUNCTION clear_sessions() FROM postgres;
GRANT ALL ON FUNCTION clear_sessions() TO postgres;
GRANT ALL ON FUNCTION clear_sessions() TO geniyz;


--
-- Name: count_sessions(); Type: ACL; Schema: web; Owner: postgres
--

REVOKE ALL ON FUNCTION count_sessions() FROM PUBLIC;
REVOKE ALL ON FUNCTION count_sessions() FROM postgres;
GRANT ALL ON FUNCTION count_sessions() TO postgres;
GRANT ALL ON FUNCTION count_sessions() TO geniyz;


--
-- Name: destroy_session(text); Type: ACL; Schema: web; Owner: postgres
--

REVOKE ALL ON FUNCTION destroy_session(sessid text) FROM PUBLIC;
REVOKE ALL ON FUNCTION destroy_session(sessid text) FROM postgres;
GRANT ALL ON FUNCTION destroy_session(sessid text) TO postgres;
GRANT ALL ON FUNCTION destroy_session(sessid text) TO geniyz;


--
-- Name: get_session_data(text); Type: ACL; Schema: web; Owner: postgres
--

REVOKE ALL ON FUNCTION get_session_data(sessid text) FROM PUBLIC;
REVOKE ALL ON FUNCTION get_session_data(sessid text) FROM postgres;
GRANT ALL ON FUNCTION get_session_data(sessid text) TO postgres;
GRANT ALL ON FUNCTION get_session_data(sessid text) TO geniyz;


--
-- Name: remove_expired(); Type: ACL; Schema: web; Owner: postgres
--

REVOKE ALL ON FUNCTION remove_expired() FROM PUBLIC;
REVOKE ALL ON FUNCTION remove_expired() FROM postgres;
GRANT ALL ON FUNCTION remove_expired() TO postgres;


--
-- Name: set_session_data(text, json, timestamp with time zone); Type: ACL; Schema: web; Owner: postgres
--

REVOKE ALL ON FUNCTION set_session_data(sessid text, sessdata json, expire timestamp with time zone) FROM PUBLIC;
REVOKE ALL ON FUNCTION set_session_data(sessid text, sessdata json, expire timestamp with time zone) FROM postgres;
GRANT ALL ON FUNCTION set_session_data(sessid text, sessdata json, expire timestamp with time zone) TO postgres;
GRANT ALL ON FUNCTION set_session_data(sessid text, sessdata json, expire timestamp with time zone) TO geniyz;


--
-- Name: valid_sessions(); Type: ACL; Schema: web; Owner: postgres
--

REVOKE ALL ON FUNCTION valid_sessions() FROM PUBLIC;
REVOKE ALL ON FUNCTION valid_sessions() FROM postgres;
GRANT ALL ON FUNCTION valid_sessions() TO postgres;


--
-- PostgreSQL database dump complete
--

